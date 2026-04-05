import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/user/user_model.dart';

abstract interface class UserRepository {
  Future<Either<RepositoryException, UserModel?>> findOneById(String id);
  Future<Either<RepositoryException, List<UserModel>>> findAllUsers(Map<String, dynamic> filters);
  Future<Either<RepositoryException, UserModel>> saveUser({required UserModel userModel, bool isFirstUser = false});
  Future<Either<RepositoryException, Unit>> deleteUser(String id);
}
