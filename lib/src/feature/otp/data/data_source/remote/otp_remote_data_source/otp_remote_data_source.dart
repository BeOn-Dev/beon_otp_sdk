import '../../../../../../core/helper/api/api_helper.dart';
import '../../../../../../core/helper/dio/endpoints.dart';
import '../../../model/otp_model/otp_model.dart';
import '../../../model/otp_send_response/otp_send_response.dart';
import '../base_otp_remote_data_source/base_otp_remote_data_source.dart';

class OtpRemoteDataSource extends BaseOtpRemoteDataSource {
  @override
  Future<OtpSendResponse> sendOtp({required OtpModel otpModel}) async {
    final body = await ApiHelper.postData(
      url: otpEndpoint(),
      token: otpModel.token,
      data: otpModel.toJson(),
    );
    return OtpSendResponse.fromJson(body);
  }
}
