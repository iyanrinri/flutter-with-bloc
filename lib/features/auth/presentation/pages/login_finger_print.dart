import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class PinFingerprintLoginPage extends StatefulWidget {
  const PinFingerprintLoginPage({super.key});

  @override
  State<PinFingerprintLoginPage> createState() => _PinFingerprintLoginPageState();
}

class _PinFingerprintLoginPageState extends State<PinFingerprintLoginPage> {
  final _pinController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _autoLoginWithBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _auth.canCheckBiometrics;
    setState(() {
      _biometricAvailable = available;
    });
  }

  Future<void> _autoLoginWithBiometric() async {
    final savedPin = await _storage.read(key: 'user_pin');
    if (savedPin != null && _biometricAvailable) {
      final didAuth = await _auth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuth) {
        _login(savedPin);
      }
    }
  }

  Future<void> _savePin(String pin) async {
    await _storage.write(key: 'user_pin', value: pin);
  }

  void _login(String pin) {
    // cek pin (bisa di-backend juga)
    if (pin == '1234') { // contoh validasi
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid PIN")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with PIN / Fingerprint")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Enter PIN"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final pin = _pinController.text;
                await _savePin(pin); // simpan PIN
                _login(pin);
              },
              child: const Text("Login with PIN"),
            ),
            if (_biometricAvailable)
              ElevatedButton(
                onPressed: _autoLoginWithBiometric,
                child: const Text("Login with Fingerprint"),
              ),
          ],
        ),
      ),
    );
  }
}
