
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';

abstract interface class ProfileServices {
  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id);
  Future<Either<ServiceException, List<Map<String, dynamic>>>> findAll({
    Map<String, dynamic>? filters,
  });
  Future<Either<ServiceException, String>> onSave(Map<String, dynamic> profileMap);
  Future<Either<ServiceException, Unit>> delete(String id);
}
