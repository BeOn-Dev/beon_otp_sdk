import '../../../data/model/otp_model/otp_model.dart';
import '../../../data/model/otp_send_response/otp_send_response.dart';
import '../../repo/base_otp_repo/base_otp_repo.dart';

class OtpUseCase {
  OtpUseCase({required this.otpRepository});

  final BaseOtpRepository otpRepository;

  Future<OtpSendResponse> sendOtp({required OtpModel otpModel}) {
    return otpRepository.sendOtp(otpModel: otpModel);
  }
}
