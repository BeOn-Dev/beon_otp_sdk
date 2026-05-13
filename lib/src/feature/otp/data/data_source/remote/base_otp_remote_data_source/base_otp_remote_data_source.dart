import '../../../model/otp_model/otp_model.dart';
import '../../../model/otp_send_response/otp_send_response.dart';

abstract class BaseOtpRemoteDataSource {
  Future<OtpSendResponse> sendOtp({required OtpModel otpModel});
}
