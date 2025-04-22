import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_event.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_state.dart';
import 'package:yukngantri/features/general/presentation/pages/dashboard_page.dart';
import 'package:yukngantri/features/auth/presentation/pages/login.dart';
import 'package:geolocator/geolocator.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
    context.read<AuthBloc>().add(const InitUserRequested());
  }

  Future<void> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Bisa tampilkan snackbar, dialog, atau navigasi ke settings
      print("User tidak memberi izin lokasi.");
    } else {
      print("Izin lokasi diberikan.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state.isLoading) return;
          if (state.user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          } else if (state.user == null) {
            await Future.delayed(Duration(seconds: 2));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
        child: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(75)),
                  child: Image(
                    image: AssetImage('assets/icon/app_icon.png'),
                    width: 150,
                    height: 150,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
