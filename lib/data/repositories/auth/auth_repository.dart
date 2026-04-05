import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';

abstract interface class AuthRepository {
  Future<Either<RepositoryException, bool>> login({required String email, required String password});
}
