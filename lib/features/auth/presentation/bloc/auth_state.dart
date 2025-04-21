// lib/features/auth/presentation/bloc/auth_state.dart
class AuthState {
  final bool isLoading;
  final String? token;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.token,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    String? token,
    Map<String, dynamic>? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}