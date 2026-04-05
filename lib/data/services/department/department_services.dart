import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';

abstract interface class DepartmentServices {
  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id);
  Future<Either<ServiceException, List<Map<String, dynamic>>>> findAll({
    Map<String, dynamic>? filters,
  });
  Future<Either<ServiceException, String>> onSave(Map<String, dynamic> departmentMap);
  Future<Either<ServiceException, Unit>> delete(String id);
}
