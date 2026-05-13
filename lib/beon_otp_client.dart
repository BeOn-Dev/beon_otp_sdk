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
  }) {
    return _useCase.sendOtp(
      otpModel: OtpModel(
        phoneNumber: phoneNumber,
        name: name,
        type: method.name,
        otpLength: otpLength,
        customCode: customCode,
        lang: lang,
        token: _token,
      ),
    );
  }

  static bool verifyOtp({required String expected, required String input}) {
    if (expected.isEmpty) return false;
    return expected.trim() == input.trim();
  }

  /// Listens for the incoming OTP SMS and returns the extracted code.
  ///
  /// **Android**: uses the SMS User Consent API (no permissions required).
  /// The OS shows a one-tap consent dialog when a matching SMS arrives. On
  /// "Allow", the SDK extracts the first run of `otpLength` digits from the
  /// SMS body and returns it. Returns `null` on timeout, dismissal, or if
  /// no digit run of that length is found.
  ///
  /// **iOS / web / desktop**: returns `null` immediately. iOS handles OTP
  /// auto-fill natively — attach `autofillHints: [AutofillHints.oneTimeCode]`
  /// and `keyboardType: TextInputType.number` to your `TextField`. Example:
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
  ///
  /// Pass [senderPhoneNumber] to restrict the listener to a specific sender.
  Future<String?> awaitOtpFromSms({
    int otpLength = 6,
    Duration timeout = const Duration(minutes: 5),
    String? senderPhoneNumber,
  }) {
    return _awaitUseCase(
      otpLength: otpLength,
      timeout: timeout,
      senderPhone: senderPhoneNumber,
    );
  }

  /// Cancels an in-flight [awaitOtpFromSms] listener. Safe to call when
  /// nothing is listening.
  Future<void> cancelOtpAutofill() => _awaitUseCase.cancel();
}
