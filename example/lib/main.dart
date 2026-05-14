import 'package:beon_otp_sdk/beon_otp_sdk.dart';
import 'package:flutter/material.dart';

import 'pin_otp_widget/pin_otp_widget.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beon OTP SDK demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final _phone = TextEditingController(text: '01153634504');
  final _name = TextEditingController(text: 'Ahmed Fadlallah');
  final _code = TextEditingController();

  String token = "SPb4sbemr5bwb7sjzCqTcL";
  OtpMethods _method = OtpMethods.sms;
  Environment _env = Environment.live;

  BeonOtpClient? _sdk;
  String? _lastBuiltToken;
  Environment? _lastBuiltEnv;

  String? _expectedCode;
  String _status = '';
  String _result = '';
  bool _sending = false;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _rebuildSdk();
  }

  void _rebuildSdk() {
    _sdk?.autofilledCode.removeListener(_onAutofill);
    _sdk?.dispose();
    _sdk = BeonOtpClient(
      token: token,
      environment: _env,
      enableLogging: true,
    );
    _lastBuiltToken = token;
    _lastBuiltEnv = _env;
    _sdk!.autofilledCode.addListener(_onAutofill);
    _sdk!.getAndroidAppSignature().then((sig) {
      if (sig != null) debugPrint('Beon Android app signature: $sig');
    });
  }

  void _onAutofill() {
    final code = _sdk?.autofilledCode.value;
    if (code != null) _code.text = code;
  }

  BeonOtpClient _client() {
    if (_sdk == null || _lastBuiltToken != token || _lastBuiltEnv != _env) {
      _rebuildSdk();
    }
    return _sdk!;
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _status = 'Sending…';
      _result = '';
      _code.clear();
    });
    try {
      final sdk = _client();
      final res = await sdk.sendOtp(
        phoneNumber: _phone.text.trim(),
        name: _name.text.trim(),
        method: _method,
        otpLength: 6,
      );
      _expectedCode = res.code;
      if (mounted) {
        setState(() {
          _status = 'OTP sent (debug code: ${res.code})';
        });
      }
    } on BeonOtpException catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error (${e.statusCode ?? '-'}): ${e.message}';
        });
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _verify() {
    setState(() => _verifying = true);
    final ok = BeonOtpClient.verifyOtp(
      expected: _expectedCode ?? '',
      input: _code.text,
    );
    setState(() {
      _result = ok ? '✅ Verified' : '❌ Wrong code';
      _verifying = false;
    });
  }

  @override
  void dispose() {
    _sdk?.autofilledCode.removeListener(_onAutofill);
    _sdk?.dispose();
    _phone.dispose();
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beon OTP SDK demo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (e.g. +20…)',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<OtpMethods>(
                segments: const [
                  ButtonSegment(value: OtpMethods.sms, label: Text('SMS')),
                  ButtonSegment(
                    value: OtpMethods.whatsapp,
                    label: Text('WhatsApp'),
                  ),
                ],
                selected: {_method},
                onSelectionChanged: (s) => setState(() => _method = s.first),
              ),
              const SizedBox(height: 8),
              SegmentedButton<Environment>(
                segments: const [
                  ButtonSegment(value: Environment.live, label: Text('Live')),
                  ButtonSegment(
                    value: Environment.staging,
                    label: Text('Staging'),
                  ),
                ],
                selected: {_env},
                onSelectionChanged: (s) => setState(() => _env = s.first),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _sending ? null : _send,
                child: Text(_sending ? 'Sending…' : '1. Send OTP'),
              ),
              if (_status.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_status),
              ],
              const SizedBox(height: 24),
              PinOtpWidget(
                controller: _code,
                length: 6,
                onComplete: (_) {
                  if (_expectedCode != null && !_verifying) _verify();
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _verifying || _expectedCode == null ? null : _verify,
                child: const Text('2. Verify'),
              ),
              if (_result.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_result, style: Theme.of(context).textTheme.titleMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
