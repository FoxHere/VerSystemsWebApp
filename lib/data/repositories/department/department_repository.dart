

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/department/department_model.dart';

abstract interface class DepartmentRepository {
  Future<Either<RepositoryException, DepartmentModel?>> findOneById(String id);
  Future<Either<RepositoryException, List<DepartmentModel>>> findAllDepartments(
    Map<String, dynamic> filters,
  );
  Future<Either<RepositoryException, String>> saveDepartment(DepartmentModel departmentModel);
  Future<Either<RepositoryException, Unit>> deleteDepartment(String id);
}
