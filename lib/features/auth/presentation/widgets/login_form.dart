import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:yukngantri/core/utils/user_helper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  bool _rememberMe = false;
  String? _savedToken;
  bool _isAuthenticating = false;
  bool _isFingerPrintEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSavedToken();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadSavedToken() async {
    final token = await _storage.read(key: 'access_token');
    if (mounted) {
      setState(() {
        _savedToken = token;
      });
    }
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!UserHelper.isValidEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email tidak valid')));
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(email: email, password: password, remember: _rememberMe),
    );
  }

  Future<void> _loginWithFingerprint() async {
    String? fingerPrintEnabled = await _storage.read(key: 'finger_print_enabled');
    _isFingerPrintEnabled = fingerPrintEnabled == '1' ? true : false;
    if (!_isFingerPrintEnabled) return;

    if (_isAuthenticating || !mounted) return;
    setState(() {
      _isAuthenticating = true;
    });

    final canAuth = await _auth.canCheckBiometrics;
    if (!canAuth || !mounted) return;

    try {
      final didAuth = await _auth.authenticate(
        localizedReason: 'Login with fingerprint',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (!mounted) return;
      if (didAuth) {
        _savedToken = await _storage.read(key: 'access_token');
        if (_savedToken != null) {
          context.read<AuthBloc>().add(LoginFingerRequested());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No saved login. Please login with email & password.'),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fingerprint authentication failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sign in",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              PasswordField(controller: _passwordController),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text("Remember me"),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Forgot Password is Coming Soon ! :)"),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8080),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                    state.isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text("Login"),
                ),
              ),
              const SizedBox(height: 10),
              // Tombol Fingerprint
              if (_savedToken != null && _isFingerPrintEnabled)
                IconButton(
                  icon: const Icon(Icons.fingerprint, size: 40),
                  onPressed: _loginWithFingerprint,
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sign Up is Coming Soon ! :)"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text("Don’t have an account? Sign up"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            // Ganti ikon berdasarkan status
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText; // Toggle status obscureText
            });
          },
        ),
      ),
    );
  }
}
