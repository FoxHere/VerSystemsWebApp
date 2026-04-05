class RepositoryException implements Exception {
  final String message;
  RepositoryException({this.message = ''});
}

final class RepositoryError extends RepositoryException {
  RepositoryError({required super.message});
}

final class RepositoryUnauthorizedException extends RepositoryException {
  RepositoryUnauthorizedException() : super(message: '');
}
