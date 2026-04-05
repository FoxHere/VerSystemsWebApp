sealed class AuthExpection implements Exception {
  final String message;
  AuthExpection({required this.message});
}

final class AuthError extends AuthExpection {
  AuthError({required super.message});
}

final class AuthUnauthorizedException extends AuthExpection {
  AuthUnauthorizedException() : super(message: '');
}
