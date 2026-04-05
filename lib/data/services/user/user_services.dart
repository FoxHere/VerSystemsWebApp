
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';

abstract interface class UsersService {
  // User Data
  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id);
  Future<Either<ServiceException, List<Map<String, dynamic>>>> findAll();
  // Profile Images
  Future<Either<ServiceException, String?>> findImgProfile();
  Future<Either<ServiceException, String>> uploadImgProfile(String imagePath);
  Future<Either<ServiceException, Unit>> delete(String id);
}
