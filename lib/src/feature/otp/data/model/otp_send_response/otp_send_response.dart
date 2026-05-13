import 'package:equatable/equatable.dart';

class OtpSendResponse extends Equatable {
  const OtpSendResponse({
    required this.code,
    this.status,
    this.message,
    this.rawData,
  });

  final String code;
  final int? status;
  final String? message;
  final Map<String, dynamic>? rawData;

  factory OtpSendResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final data = raw is Map ? Map<String, dynamic>.from(raw) : null;
    return OtpSendResponse(
      code: data?['otp']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : null,
      message: json['message']?.toString(),
      rawData: data,
    );
  }

  @override
  List<Object?> get props => [code, status, message];
}
