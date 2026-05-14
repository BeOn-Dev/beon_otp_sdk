import 'package:dio/dio.dart';

import '../../util/exceptions/beon_otp_exception.dart';
import '../../util/models/api_models/error_response_model/error_response_model.dart';
import '../dio/dio_helper.dart';

class ApiHelper {
  static Future<Map<String, dynamic>> postData({
    required String url,
    required String token,
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: url,
        data: data,
        query: query,
        token: token,
        options: options,
      );
      return _unwrap(response);
    } on BeonOtpException {
      rethrow;
    } on DioException catch (e) {
      throw _fromDioException(e);
    } catch (e) {
      throw BeonOtpException(message: e.toString(), cause: e);
    }
  }

  static Future<Map<String, dynamic>> getData({
    required String url,
    required String token,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: url,
        query: query,
        token: token,
        data: data,
        cancelToken: cancelToken,
      );
      return _unwrap(response);
    } on BeonOtpException {
      rethrow;
    } on DioException catch (e) {
      throw _fromDioException(e);
    } catch (e) {
      throw BeonOtpException(message: e.toString(), cause: e);
    }
  }

  static Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw BeonOtpException(
        message: 'Unexpected response body.',
        statusCode: response.statusCode,
      );
    }
    if (body['status'] == 200) {
      return body;
    }
    final error = ErrorResponseModel.fromJson(body);
    throw BeonOtpException(
      message: error.message ?? 'Request failed.',
      statusCode: error.status ?? response.statusCode,
      errors: error.errors,
    );
  }

  static BeonOtpException _fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return BeonOtpException(
          message: 'Network connection timed out.',
          cause: e,
        );
      case DioExceptionType.badCertificate:
        return BeonOtpException(message: 'Invalid TLS certificate.', cause: e);
      case DioExceptionType.cancel:
        return BeonOtpException(message: 'Request cancelled.', cause: e);
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return BeonOtpException(
          message: e.message ?? 'Network request failed.',
          statusCode: e.response?.statusCode,
          cause: e,
        );
    }
  }
}
