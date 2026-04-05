

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/data/repositories/department/department_repository.dart';
import 'package:versystems_app/data/services/department/department_services.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentServices _departmentService;
  final UserServicesImpl _userServices;

  DepartmentRepositoryImpl({
    required DepartmentServices departmentService,
    required UserServicesImpl userServices,
  }) : _departmentService = departmentService,
       _userServices = userServices;

  @override
  Future<Either<RepositoryException, DepartmentModel?>> findOneById(String id) async {
    try {
      final result = await _departmentService.findOne(id);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (Map<String, dynamic> departmentData) {
          if (departmentData.isEmpty) return Right(null);
          final departmentModel = DepartmentModel.fromJson(departmentData);
          return Right(departmentModel);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório, erro: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, List<DepartmentModel>>> findAllDepartments(
    Map<String, dynamic> filters,
  ) async {
    try {
      final result = await _departmentService.findAll(filters: filters);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (List<Map<String, dynamic>> departments) {
          if (departments.isEmpty) return Right(<DepartmentModel>[]);
          final departmentModelList = departments
              .map((departmentMap) => DepartmentModel.fromJson(departmentMap))
              .toList();
          return Right(departmentModelList);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório, erro: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, String>> saveDepartment(
    DepartmentModel departmentModel,
  ) async {
    try {
      final departmentMap = departmentModel.toJsonForFirebase();
      if (departmentModel.id.isEmpty) departmentMap.remove('id');
      final result = await _departmentService.onSave(departmentMap);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao salvar departamento: ${se.message}'));
        },
        (String departmentId) async {
          return Right(departmentId);
        },
      );
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao tratar departamentos ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> deleteDepartment(String id) async {
    try {
      final usersResult = await _userServices.findOneByDepartment(id);
      return await usersResult.fold((se) => Left(RepositoryException(message: se.message)), (
        users,
      ) async {
        if (users.isNotEmpty) {
          return Left(RepositoryException(message: 'Usuários vinculados ao departamento'));
        }
        final result = await _departmentService.delete(id);
        return result.fold(
          (ServiceException se) async {
            return Left(
              RepositoryException(message: 'Erro ao deletar departamento: ${se.message}'),
            );
          },
          (Unit unit) async {
            return Right(unit);
          },
        );
      });
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao deletar departamento ${e.toString()}'),
      );
    }
  }
}
