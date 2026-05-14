# beon_otp_sdk

A lightweight Flutter client for the BeOn OTP service — send and verify
one-time passwords, with **zero-tap Android auto-fill** (SMS Retriever API)
and native iOS keyboard-suggestion auto-fill baked in. Logic only, no UI.

## Features

- Send OTP via SMS or WhatsApp.
- Verify entered code against the expected value (local equality, no
  network round-trip on verify).
- **Zero-tap auto-fill on Android.** The SDK arms the SMS Retriever
  listener automatically inside `sendOtp`, before the HTTP request leaves
  the device — no system consent dialog, no notification banner, no race
  with SMS arrival. The detected code is published through a
  `ValueNotifier<String?>` you subscribe to once.
- **iOS keyboard-suggestion auto-fill** via `AutofillHints.oneTimeCode`.
- Opt-out flag for apps that don't want any auto-fill behaviour.

## Install

```bash
flutter pub add beon_otp_sdk
```

## Quick start

```dart
import 'package:beon_otp_sdk/beon_otp_sdk.dart';
import 'package:flutter/material.dart';

final _otp = TextEditingController();
final sdk = BeonOtpClient(token: 'YOUR_BEON_TOKEN');

// Subscribe once. Fires automatically when an SMS arrives.
sdk.autofilledCode.addListener(() {
  final code = sdk.autofilledCode.value;
  if (code != null) _otp.text = code;
});

// Send OTP — the SMS Retriever listener is armed internally first.
final res = await sdk.sendOtp(
  phoneNumber: '+201001234567',
  name: 'Jane Doe',
  method: OtpMethods.sms,
);

// User types (or auto-fill fires) → verify.
final ok = BeonOtpClient.verifyOtp(
  expected: res.code,
  input: _otp.text,
);
```

Don't forget to release resources:

```dart
@override
void dispose() {
  sdk.dispose(); // cancels the Retriever listener + disposes the notifier
  _otp.dispose();
  super.dispose();
}
```

## Android setup — zero-tap auto-fill

Zero-tap auto-fill works only when the incoming SMS ends with this app's
11-character signing hash. The hash differs per APK signing key (debug,
release, Play-store-signed each produce a different value).

Fetch the hash for the running build:

```dart
final sig = await sdk.getAndroidAppSignature();
debugPrint('Beon Android app signature: $sig');
```

Pass the value to your BeOn backend contact so the OTP SMS template
becomes:

```
<#> Your verification code for BeOn is 123456 Please do not share it with anyone.
{your-11-char-hash}
```

The `<#>` prefix is recommended — it suppresses the Android notification
banner. The trailing hash on its own line is **required**; without it the
Retriever listener silently times out after five minutes.

No `AndroidManifest.xml` permissions are required. The SMS Retriever API
ships with Google Play services.

## iOS setup — keyboard-suggestion auto-fill

Apple does not expose a fully-headless SMS auto-fill path. The standard
pattern is to declare the OTP field's content type, and iOS surfaces the
incoming code as a keyboard suggestion the user taps:

```dart
TextField(
  controller: _otp,
  keyboardType: TextInputType.number,
  autofillHints: const [AutofillHints.oneTimeCode],
);
```

That's the maximum automation iOS permits. No backend SMS-template change
is required for iOS.

## Opting out of auto-fill

```dart
final sdk = BeonOtpClient(token: '…', enableAutofill: false);
```

When `enableAutofill: false`:

- `sendOtp` does not arm the SMS Retriever listener.
- The request body does not include `app_signature`, so the BeOn backend
  falls back to its legacy SMS template (no `<#>` prefix, no trailing
  hash).
- `awaitOtpFromSms()` returns `null` immediately.
- `autofilledCode` stays `null` for the lifetime of the client.
- `getAndroidAppSignature()` still returns the real hash — useful for
  one-off configuration tasks even when auto-fill is disabled.

## API reference

- `BeonOtpClient({required String token, bool enableAutofill = true,
  Duration timeout})` — construct the client.
- `Future<OtpSendResponse> sendOtp({...})` — send an OTP and arm the
  Android auto-fill listener (when enabled).
- `static bool verifyOtp({required String expected, required String input})`
  — local equality check.
- `Future<String?> getAndroidAppSignature()` — 11-char signing hash on
  Android, `null` elsewhere.
- `Future<String?> awaitOtpFromSms({int otpLength, Duration timeout})` —
  manual one-shot listener, kept for advanced flows.
- `Future<void> cancelOtpAutofill()` — cancel the in-flight listener.
- `Future<void> dispose()` — release resources.
- `ValueNotifier<String?> autofilledCode` — the canonical auto-fill
  surface.

## Error handling

`sendOtp` throws `BeonOtpException` on non-2xx responses or network
failures:

```dart
try {
  await sdk.sendOtp(...);
} on BeonOtpException catch (e) {
  // e.statusCode, e.message, e.errors
}
```

## License

MIT — see [LICENSE](LICENSE).
