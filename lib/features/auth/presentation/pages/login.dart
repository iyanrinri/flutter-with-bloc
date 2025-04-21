import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import '../bloc/auth_bloc.dart';

import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../widgets/back_button_header.dart';
import '../widgets/wave_clipper.dart';
import '../widgets/welcome_slide.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController _pageController = PageController();
  final storage = const FlutterSecureStorage();
  bool _isWelcomeDone = false;

  @override
  void initState() {
    super.initState();
    _checkWelcome();
  }

  Future<void> _checkWelcome() async {
    final doneWelcome = await storage.read(key: 'done_welcome');
    if (doneWelcome == '1') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(1);
      });
    }
    setState(() {
      _isWelcomeDone = true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    await storage.write(key: 'done_welcome', value: '1');
  }

  void _previousPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Stack _loginSlider() {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipPath(
            clipper: WaveClipper(),
            child: Container(color: Colors.white),
          ),
        ),
        if (!_isWelcomeDone) BackButtonHeader(onBack: _previousPage),
        const LoginForm(),
      ],
    );
  }

  Stack _welcomeSlider() {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipPath(
            clipper: WaveClipper(),
            child: Container(color: Colors.white),
          ),
        ),
        WelcomeSlide(onNext: _nextPage),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isWelcomeDone) {
      // Tunggu pengecekan selesai
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DoubleBackToExitWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.user != null) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
            if (state.errorMessage != null && state.errorMessage != 'No token found') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text(state.errorMessage!),
                ),
              );
            }
          },
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [_welcomeSlider(), _loginSlider()],
          ),
        ),
      ),
    );
  }
}
