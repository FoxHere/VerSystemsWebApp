

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/repositories/formulary/formulary_repository.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/data/services/formulary/formulary_services.dart';

class FormularyRepositoryImpl implements FormularyRepository {
  final FormularyServices _formularyServices;
  final ActivityServices _activityServices;

  FormularyRepositoryImpl({
    required FormularyServices formularyServices,
    required ActivityServices activityServices,
  }) : _formularyServices = formularyServices,
       _activityServices = activityServices;

  @override
  Future<Either<RepositoryException, String>> saveFormulary(FormularyModel formularyModel) async {
    try {
      final formularyMap = formularyModel.toJsonForFirebase();
      if (formularyModel.id.isEmpty) formularyMap.remove('id');
      final result = await _formularyServices.onSave(formularyMap);
      return result.fold(
        (ServiceException se) => Left(
          RepositoryException(message: 'Erro ao salvar formulário: ${se.message}'),
        ),
        (String userId) async {
          return Right(userId);
        },
      );
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao tratar formulários ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, List<FormularyModel>>> findAllFormularies() async {
    try {
      final result = await _formularyServices.findAll();
      return await result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: se.message));
        },
        (List<Map<String, dynamic>> formsMap) async {
          if (formsMap.isEmpty) {
            return Right(<FormularyModel>[]);
          }
          final questionaryModel = formsMap
              .map((formMap) => FormularyModel.fromJson(formMap))
              .toList();
          return Right(questionaryModel);
        },
      );
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao tratar formulários ${e.toString()}'),
      );
    }
  }

  Future<Either<RepositoryException, Unit>> deleteFormulary(String id) async {
    try {
      final activityResult = await _activityServices.findOneByFormulary(id);
      return await activityResult.fold(
        (ServiceException se) {
          return Left(RepositoryException(message: se.message));
        },
        (List<Map<String, dynamic>> activities) async {
          if (activities.isNotEmpty) {
            return Left(RepositoryException(message: 'Há Atividades vinculadas ao formulário'));
          }
          final result = await _formularyServices.delete(id);
          return result.fold(
            (ServiceException se) async {
              return Left(
                RepositoryException(message: 'Erro ao deletar o perfil: ${se.message}'),
              );
            },
            (Unit unit) async {
              return Right(unit);
            },
          );
        },
      );
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao deletar o formulário ${e.toString()}'),
      );
    }
  }
}
