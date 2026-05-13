// ignore_for_file: avoid_print

/// Dev tool — generates the obfuscated URL/path constants pasted into
/// `lib/src/core/helper/dio/endpoints.dart`.
///
/// Run: `dart run tool/obfuscate.dart`
/// Copy the three lines from stdout into endpoints.dart.
///
/// This file is NOT shipped with the package (it sits outside `lib/`).
library;

import 'dart:convert';

const int _key = 0x5A;

String _obfuscate(String input) {
  final bytes = utf8.encode(input);
  final xored = bytes.map((b) => b ^ _key).toList(growable: false);
  return base64.encode(xored);
}

void main() {
  final pairs = <String, String>{
    '_liveObf': 'https://v3.api.beon.chat/api/v3/',
    '_stageObf': 'https://stage.api.beon.chat/api/v3/',
    '_otpPathObf': 'messages/otp',
  };
  pairs.forEach((name, plain) {
    print("const String $name = '${_obfuscate(plain)}';");
  });
}
