import 'package:yukngantri/core/network/api_service.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';


class UserHelper {
  static Future<bool> checkUser(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    print('checkUser: Dispatching InitUserRequested');
    authBloc.add(const InitUserRequested());

    // Wait for the first relevant state (e.g., user != null or isLoading == false)
    final state = await authBloc.stream.firstWhere(
          (state) => !state.isLoading || state.user != null,
      orElse: () => const AuthState(),
    ).timeout(
      const Duration(seconds: 5), // Prevent indefinite waiting
      onTimeout: () {
        print('checkUser: Timed out waiting for AuthState');
        return const AuthState();
      },
    );

    print('checkUser: State received, user=${state.user}');
    return state.user != null;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return emailRegex.hasMatch(email);
  }

  static String capitalizeName(String name) {
    if (name.isEmpty) return '';
    return name
        .split(' ')
        .map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(' ');
  }

  static bool isAdmin(Map<String, dynamic> user) {
    return user['role'] == 'admin';
  }

  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
  }
}
