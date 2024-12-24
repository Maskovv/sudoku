enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? error;
  final String? userId;
  final bool isLoading;
  
  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.userId,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    String? userId,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthInitial extends AuthState {
  const AuthInitial({
    AuthStatus status = AuthStatus.initial,
    String? error,
    String? userId,
  }) : super(status: status, error: error, userId: userId);
}

class AuthLoading extends AuthState {
  const AuthLoading() : super(status: AuthStatus.initial);
}

class AuthSuccess extends AuthState {
  const AuthSuccess() : super(status: AuthStatus.authenticated);
}

class AuthError extends AuthState {
  const AuthError(String error) : super(status: AuthStatus.unauthenticated, error: error);
}