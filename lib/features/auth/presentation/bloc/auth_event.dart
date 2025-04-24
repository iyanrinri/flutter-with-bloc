abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool remember;

  const LoginRequested({
    required this.email,
    required this.password,
    this.remember = false,
  });
}

class LoginFingerRequested extends AuthEvent {
  const LoginFingerRequested();
}

class InitUserRequested extends AuthEvent {
  const InitUserRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}