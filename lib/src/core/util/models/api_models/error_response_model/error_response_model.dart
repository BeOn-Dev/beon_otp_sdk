import 'package:equatable/equatable.dart';

class ErrorResponseModel extends Equatable {
  const ErrorResponseModel({this.status, this.message, this.errors});

  final int? status;
  final String? message;
  final Map<String, dynamic>? errors;

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    return ErrorResponseModel(
      status: json['status'] is int ? json['status'] as int : null,
      message: json['message']?.toString(),
      errors: rawErrors is Map ? Map<String, dynamic>.from(rawErrors) : null,
    );
  }

  @override
  List<Object?> get props => [status, message, errors];
}
