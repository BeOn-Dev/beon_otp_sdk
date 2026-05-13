import '../../../data/model/otp_model/otp_model.dart';
import '../../../data/model/otp_send_response/otp_send_response.dart';

abstract class BaseOtpRepository {
  Future<OtpSendResponse> sendOtp({required OtpModel otpModel});
}
