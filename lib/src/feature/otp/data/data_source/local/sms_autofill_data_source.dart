import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:otp_autofill/otp_autofill.dart';

class SmsAutofillDataSource {
  OTPInteractor? _interactor;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<String?> startListening({
    required Duration timeout,
    String? senderPhone,
  }) async {
    if (!_isAndroid) return null;

    final interactor = _interactor ??= OTPInteractor();
    try {
      return await interactor.startListenUserConsent(senderPhone).timeout(
        timeout,
        onTimeout: () async {
          await _safeStop(interactor);
          return null;
        },
      );
    } catch (_) {
      await _safeStop(interactor);
      return null;
    }
  }

  Future<void> stop() async {
    final interactor = _interactor;
    _interactor = null;
    if (interactor != null) await _safeStop(interactor);
  }

  Future<void> _safeStop(OTPInteractor interactor) async {
    try {
      await interactor.stopListenForCode();
    } catch (_) {
      // best-effort cleanup
    }
  }
}
