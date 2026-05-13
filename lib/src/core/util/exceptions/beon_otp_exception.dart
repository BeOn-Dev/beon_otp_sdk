class BeonOtpException implements Exception {
  BeonOtpException({
    required this.message,
    this.statusCode,
    this.errors,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final Object? cause;

  @override
  String toString() => 'BeonOtpException(${statusCode ?? '-'}): $message';
}
