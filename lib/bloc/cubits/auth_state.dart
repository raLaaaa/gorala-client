part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();
}

class Foreign extends AuthState {
  const Foreign();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User Auth;
  const Authenticated(this.Auth);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Authenticated && o.Auth == Auth;
  }

  @override
  int get hashCode => Auth.hashCode;
}

class AuthError extends AuthState {
  final String message;
  final String username;
  const AuthError(this.message, this.username);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AuthError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class RegistrationError extends AuthState {
  final String message;

  const RegistrationError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is RegistrationError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}