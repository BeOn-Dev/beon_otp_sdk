/// Beon OTP SDK — logic-only client for sending and verifying OTPs.
///
/// ```dart
/// import 'package:beon_otp_sdk/beon_otp_sdk.dart';
///
/// final sdk = BeonOtpClient(token: 'your-beon-token');
///
/// try {
///   final res = await sdk.sendOtp(
///     phoneNumber: '+201001234567',
///     name: 'John',
///     method: OtpMethods.sms,
///   );
///   final ok = BeonOtpClient.verifyOtp(
///     expected: res.code,
///     input: userInput,
///   );
/// } on BeonOtpException catch (e) {
///   // handle e.message / e.statusCode / e.errors
/// }
/// ```
library;

export 'beon_otp_client.dart' show BeonOtpClient;
export 'src/core/util/exceptions/beon_otp_exception.dart' show BeonOtpException;
export 'src/feature/otp/data/model/enums/otp_methods/otp_methods.dart'
    show OtpMethods;
export 'src/feature/otp/data/model/otp_send_response/otp_send_response.dart'
    show OtpSendResponse;
