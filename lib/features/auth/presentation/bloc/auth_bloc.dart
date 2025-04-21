// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yukngantri/core/network/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final FlutterSecureStorage storage;

  AuthBloc({
    required this.apiService,
    required this.storage,
  }) : super(const AuthState()) {
    on<LoginRequested>(_onLoginRequested);
    on<InitUserRequested>(_onInitUserRequested);
    on<LogoutRequested>(_onLogoutRequested);

    // Inisialisasi token saat Bloc dibuat
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await storage.read(key: 'token');
    if (token != null) {
      emit(state.copyWith(token: token));
      add(const InitUserRequested()); // Inisialisasi pengguna jika token ada
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final response = await apiService.sendRequest(
      method: 'POST',
      endpoint: '/auth/login',
      data: {
        'email': event.email,
        'password': event.password,
        'remember': event.remember,
      },
    );

    if (response == null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Something wrong with your Network try again in few minutes',
      ));
      return;
    }

    if (response.statusCode == 200) {
      final data = response.data;
      final token = data['access_token'];
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'access_token', value: token);
      emit(state.copyWith(token: token, isLoading: false));

      // Inisialisasi pengguna setelah login
      add(const InitUserRequested());
    } else {
      final responseData = response.data;
      final message = responseData['message'] ?? 'Terjadi kesalahan yang tidak diketahui.';
      final errorMsg = message is String ? message : message.join(' ');
      emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
    }
  }

  Future<void> _onInitUserRequested(
      InitUserRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final storedToken = await storage.read(key: 'token');
    if (storedToken != null) {
      try {
        final userResponse = await apiService.sendRequest(
          method: 'GET',
          endpoint: '/user',
          useAuth: true,
        ).timeout(const Duration(seconds: 5));

        if (userResponse?.statusCode == 200) {
          final userData = userResponse?.data;
          await storage.write(key: 'user', value: jsonEncode(userData));
          emit(state.copyWith(
            user: userData,
            token: storedToken,
            isLoading: false,
          ));
        } else {
          await storage.delete(key: 'token');
          emit(state.copyWith(
            token: null,
            user: null,
            isLoading: false,
            errorMessage: 'Invalid token, please login again',
          ));
        }
      } catch (e) {
        await storage.delete(key: 'token');
        emit(state.copyWith(
          token: null,
          user: null,
          isLoading: false,
          errorMessage: 'Failed to fetch user data: $e',
        ));
      }
    } else {
      emit(state.copyWith(
        isLoading: false,
        token: null,
        user: null,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'user');
    emit(const AuthState());
  }
}