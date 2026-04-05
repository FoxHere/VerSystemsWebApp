import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/repositories/activity/activity_repository.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityServices _activityServices;

  ActivityRepositoryImpl({required ActivityServices activityServices}) : _activityServices = activityServices;

  @override
  Future<Either<RepositoryException, ActivityModel?>> findOneById(String id) async {
    // Essa função precisa buscar os dados do serviço de atividades e de formulários
    try {
      final result = await _activityServices.findOne(id);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (Map<String, dynamic> activityMap) {
          if (activityMap.isEmpty) return Right(null);
          final profileModel = ActivityModel.fromJson(activityMap);
          return Right(profileModel);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, List<ActivityModel>>> findAllActivities(Map<String, dynamic> filters) async {
    try {
      final result = await _activityServices.findAll(filters: filters);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (List<Map<String, dynamic>> activities) {
          if (activities.isEmpty) return Right(<ActivityModel>[]);
          final activityModelList = activities.map((activityMap) => ActivityModel.fromJson(activityMap)).toList();
          return Right(activityModelList);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório: ${e.toString()}'));
    }
  }

  Future<Either<RepositoryException, Unit>> updateActivityStatus(ActivityModel activityModel) async {
    try {
      final activityMap = activityModel.toJsonForFirebase();

      final result = await _activityServices.updateActivityStatus(activityMap);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao atualizar status: ${se.message}'));
        },
        (Unit unit) async {
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao tratar atividade ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, String>> saveActivity(ActivityModel activityModel) async {
    try {
      final activityMap = activityModel.toJsonForFirebase();
      if (activityModel.id.isEmpty) activityMap.remove('id');
      final result = await _activityServices.onSave(activityMap);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao salvar atividade: ${se.message}'));
        },
        (String activityId) async {
          return Right(activityId);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao tratar atividade ${e.toString()}'));
    }
  }

  Future<Either<RepositoryException, Unit>> deleteActivity(String id) async {
    try {
      final activityResult = await _activityServices.findOne(id);
      return await activityResult.fold(
        (ServiceException se) {
          return Left(RepositoryException(message: se.message));
        },
        (Map<String, dynamic> activityMap) async {
          if (ActivityStatusEnumExtension.fromString(activityMap['status']) != ActivityStatusEnum.inactive) {
            return Left(RepositoryException(message: 'não é possível deletar uma atividade ativa'));
          }
          final result = await _activityServices.delete(id);
          return result.fold(
            (ServiceException se) async {
              return Left(RepositoryException(message: 'Erro ao deletar o perfil: ${se.message}'));
            },
            (Unit unit) async {
              return Right(unit);
            },
          );
          // return Right(unit);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao deletar o formulário ${e.toString()}'));
    }
  }
}
