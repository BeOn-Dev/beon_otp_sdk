import 'package:equatable/equatable.dart';

class OtpModel extends Equatable {
  const OtpModel({
    this.phoneNumber,
    this.name,
    this.otpLength,
    this.customCode,
    this.lang,
    this.type,
    required this.token,
  });

  final String? phoneNumber;
  final String? name;
  final int? otpLength;
  final String? customCode;
  final String? lang;
  final String? type;
  final String token;

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'name': name,
        'otp_length': otpLength,
        if (customCode != null) 'custom_code': customCode,
        'lang': lang,
        'type': type,
      };

  @override
  List<Object?> get props => [phoneNumber, name, otpLength, customCode, lang, type];
}
