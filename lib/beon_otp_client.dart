import 'src/core/helper/dio/dio_helper.dart';
import 'src/core/helper/dio/endpoints.dart';
import 'src/feature/otp/data/data_source/local/sms_autofill_data_source.dart';
import 'src/feature/otp/data/data_source/remote/otp_remote_data_source/otp_remote_data_source.dart';
import 'src/feature/otp/data/model/enums/otp_methods/otp_methods.dart';
import 'src/feature/otp/data/model/otp_model/otp_model.dart';
import 'src/feature/otp/data/model/otp_send_response/otp_send_response.dart';
import 'src/feature/otp/data/repo/otp_repo_impl/otp_repo_impl.dart';
import 'src/feature/otp/domain/use_case/await_otp_use_case/await_otp_use_case.dart';
import 'src/feature/otp/domain/use_case/otp_use_case/otp_use_case.dart';

class BeonOtpClient {
  BeonOtpClient({
    required String token,
    Environment environment = Environment.live,
    Duration timeout = const Duration(seconds: 30),
    bool enableLogging = false,
  }) : _token = token {
    DioHelper.init(
      environment: environment,
      timeout: timeout,
      enableLogging: enableLogging,
    );
    _useCase = OtpUseCase(
      otpRepository: OtpRepositoryImplementation(
        dataSource: OtpRemoteDataSource(),
      ),
    );
    _awaitUseCase = AwaitOtpUseCase(source: SmsAutofillDataSource());
  }

  final String _token;
  late final OtpUseCase _useCase;
  late final AwaitOtpUseCase _awaitUseCase;

  Future<OtpSendResponse> sendOtp({
    required String phoneNumber,
    required String name,
    required OtpMethods method,
    int otpLength = 6,
    String? customCode,
    String lang = 'en',
  }) async {
    String? appSignature = await getAndroidAppSignature();
    return _useCase.sendOtp(
      otpModel: OtpModel(
        phoneNumber: phoneNumber,
        name: name,
        type: method.name,
        otpLength: otpLength,
        customCode: customCode,
        lang: lang,
        token: _token,
        appSignature: appSignature,
      ),
    );
  }

  static bool verifyOtp({required String expected, required String input}) {
    if (expected.isEmpty) return false;
    return expected.trim() == input.trim();
  }

  /// Listens for the incoming OTP SMS and returns the extracted code.
  ///
  /// **Android — zero-tap autofill**: uses the SMS Retriever API. No
  /// permissions, no consent dialog, no user interaction. The listener fires
  /// silently the moment a matching SMS arrives, the SDK extracts the first
  /// run of `otpLength` digits from the body and returns it.
  ///
  /// This **requires the OTP SMS to end with this app's 11-character signing
  /// hash** (and is conventionally prefixed with `<#>`):
  ///
  /// ```
  /// <#> Your Beon verification code is 123456
  /// ABC123def45
  /// ```
  ///
  /// Fetch the hash with [getAndroidAppSignature] and hand it to your backend
  /// so it can be baked into the SMS template (the hash differs per build
  /// variant — debug, release, Play-store-signed all produce different
  /// values). Without the hash the listener silently times out.
  ///
  /// **iOS / web / desktop**: returns `null` immediately. iOS handles OTP
  /// auto-fill natively — attach `autofillHints: [AutofillHints.oneTimeCode]`
  /// and `keyboardType: TextInputType.number` to your `TextField` and the
  /// OS surfaces the incoming code in the keyboard suggestion bar. Example:
  ///
  /// ```dart
  /// final controller = TextEditingController();
  /// sdk.awaitOtpFromSms(otpLength: 6).then((code) {
  ///   if (code != null) controller.text = code;
  /// });
  /// TextField(
  ///   controller: controller,
  ///   keyboardType: TextInputType.number,
  ///   autofillHints: const [AutofillHints.oneTimeCode],
  /// );
  /// ```
  Future<String?> awaitOtpFromSms({
    int otpLength = 6,
    Duration timeout = const Duration(minutes: 5),
    @Deprecated(
      'Ignored since switching to the SMS Retriever API on Android — the '
      'Retriever filters by app-signing hash, not sender phone. Kept for '
      'source compatibility; will be removed in a future major version.',
    )
    String? senderPhoneNumber,
  }) {
    return _awaitUseCase(otpLength: otpLength, timeout: timeout);
  }

  /// Cancels an in-flight [awaitOtpFromSms] listener. Safe to call when
  /// nothing is listening.
  Future<void> cancelOtpAutofill() => _awaitUseCase.cancel();

  /// Returns this app's 11-character signing hash that the Beon backend must
  /// embed at the end of the OTP SMS for zero-tap Android autofill to fire
  /// (see [awaitOtpFromSms]).
  ///
  /// The hash differs per build variant — debug, release, and Play-store-
  /// signed builds each produce a different value, so register all variants
  /// you ship.
  ///
  /// Returns `null` on iOS, web, and desktop.
  Future<String?> getAndroidAppSignature() => _awaitUseCase.getAppSignature();
}
