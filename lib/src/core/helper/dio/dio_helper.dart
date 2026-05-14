import 'package:dio/dio.dart';

import 'endpoints.dart';

class DioHelper {
  static Dio? _dio;
  static bool _initialized = false;

  static Dio get dio {
    if (!_initialized || _dio == null) {
      throw StateError(
        'DioHelper has not been initialized. Construct a BeonOtpClient first.',
      );
    }
    return _dio!;
  }

  static void init({Duration timeout = const Duration(seconds: 30)}) {
    if (_initialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: resolveBaseUrl(),
        receiveDataWhenStatusError: true,
        followRedirects: false,
        validateStatus: (_) => true,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
      ),
    );

    _initialized = true;
  }

  static Map<String, dynamic> _defaultHeaders(String? token) {
    return {
      'Authorization': 'Bearer $token',
      'beon-token': token,
      'Accept': 'application/json',
      'Accept-Language': 'en',
      'Content-Type': 'application/json',
      'lang': 'en',
    };
  }

  static Future<Response<dynamic>> getData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
    CancelToken? cancelToken,
    Map<String, dynamic>? data,
  }) {
    dio.options.headers = _defaultHeaders(token);

    return dio.get(
      url,
      queryParameters: query,
      data: data,
      cancelToken: cancelToken,
      options: Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
  }

  static Future<Response<dynamic>> postData({
    required String url,
    Map<String, dynamic>? query,
    dynamic data,
    String? token,
    Options? options,
  }) {
    dio.options.headers = options?.headers ?? _defaultHeaders(token);

    return dio.post(
      url,
      queryParameters: query,
      data: data,
      options:
          options ??
          Options(
            validateStatus: (_) => true,
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
    );
  }
}
