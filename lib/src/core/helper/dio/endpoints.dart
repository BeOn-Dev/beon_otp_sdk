// SECURITY NOTE
// ---------------
// The host strings below are obfuscated (XOR with a fixed key, then
// base64). Plaintext URLs do not appear in source or in `strings`
// output of a release binary.
//
// This raises the cost of casual extraction only. A debugger attached
// to a running process can still read the decoded URL at the moment
// Dio dispatches the request. True hiding requires routing through a
// server-side proxy we control.
//
// Regenerate via: `dart run tool/obfuscate.dart`
library;

import 'dart:convert';

enum Environment { live, staging }

const int _key = 0x5A;
const String _liveObf = 'Mi4uKilgdXUsaXQ7KjN0OD81NHQ5MjsudTsqM3UsaXU=';
const String _stageObf = 'Mi4uKilgdXUpLjs9P3Q7KjN0OD81NHQ5MjsudTsqM3UsaXU=';
const String _otpPathObf = 'Nz8pKTs9Pyl1NS4q';

String _decode(String b64) {
  final bytes = base64.decode(b64);
  final out = List<int>.filled(bytes.length, 0);
  for (var i = 0; i < bytes.length; i++) {
    out[i] = bytes[i] ^ _key;
  }
  return utf8.decode(out);
}

class _Endpoints {
  const _Endpoints._();

  static String? _liveCache;
  static String? _stageCache;
  static String? _otpPathCache;

  static String baseUrlFor(Environment env) {
    switch (env) {
      case Environment.live:
        return _liveCache ??= _decode(_liveObf);
      case Environment.staging:
        return _stageCache ??= _decode(_stageObf);
    }
  }

  static String get otpPath => _otpPathCache ??= _decode(_otpPathObf);
}

String resolveBaseUrl(Environment env) => _Endpoints.baseUrlFor(env);

String otpEndpoint() => _Endpoints.otpPath;
