import '../../../domain/repo/base_otp_repo/base_otp_repo.dart';
import '../../data_source/remote/base_otp_remote_data_source/base_otp_remote_data_source.dart';
import '../../model/otp_model/otp_model.dart';
import '../../model/otp_send_response/otp_send_response.dart';

class OtpRepositoryImplementation extends BaseOtpRepository {
  OtpRepositoryImplementation({required this.dataSource});

  final BaseOtpRemoteDataSource dataSource;

  @override
  Future<OtpSendResponse> sendOtp({required OtpModel otpModel}) {
    return dataSource.sendOtp(otpModel: otpModel);
  }
}
