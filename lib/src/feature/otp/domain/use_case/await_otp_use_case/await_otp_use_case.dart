import '../../../data/data_source/local/sms_autofill_data_source.dart';

class AwaitOtpUseCase {
  AwaitOtpUseCase({required this.source});

  final SmsAutofillDataSource source;

  Future<String?> call({
    required int otpLength,
    required Duration timeout,
  }) async {
    final body = await source.startListening(timeout: timeout);
    if (body == null) return null;
    final match = RegExp('\\b\\d{$otpLength}\\b').firstMatch(body);
    return match?.group(0);
  }

  Future<String?> getAppSignature() => source.getAppSignature();

  Future<void> cancel() => source.stop();
}
