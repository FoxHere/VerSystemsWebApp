import 'dart:developer';

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/repositories/task/task_repository.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_functions_service.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final ActivityServices _activityServices;
  final ImageServices _imageServices;
  // final DashboardFunctionsService _dashboardFunctionsService;

  TaskRepositoryImpl({
    required ActivityServices activityServices,
    required ImageServices imageServices,
    required DashboardFunctionsService dashboardFunctionsService,
  }) : _activityServices = activityServices,
       _imageServices = imageServices;
  //  _dashboardFunctionsService = dashboardFunctionsService;

  @override
  Future<Either<RepositoryException, ActivityModel?>> findOneById(String id) async {
    // Essa função precisa buscar os dados do serviço de atividades e de formulários
    try {
      final result = await _activityServices.findOne(id);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (Map<String, dynamic> taskMap) {
          if (taskMap.isEmpty) return Right(null);
          final profileModel = ActivityModel.fromJson(taskMap);
          return Right(profileModel);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, List<ActivityModel>>> findAllTasks(Map<String, dynamic> filters) async {
    try {
      final result = await _activityServices.findAll(filters: filters);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (List<Map<String, dynamic>> activities) {
          if (activities.isEmpty) return Right(<ActivityModel>[]);
          final taskModelList = activities.map((taskMap) => ActivityModel.fromJson(taskMap)).toList();
          // Sorting by active status first
          taskModelList.sort((a, b) {
            final aIsActive = a.status.label.toLowerCase() == 'active';
            final bIsActive = b.status.label.toLowerCase() == 'active';
            return bIsActive.toString().compareTo(aIsActive.toString());
          });
          return Right(taskModelList);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> saveTask(
    ActivityModel taskModel,
    List<ImageItemModel> imagesToRemove, {
    ActivityStatusEnum newStatus = ActivityStatusEnum.editing,
  }) async {
    try {
      // ------------------------------------------------------------------ IMAGE UPLOAD
      for (final section in taskModel.formulary!.sections) {
        for (final question in section.questions) {
          final isSignatureQuestion = question.questionType == 'signatureInput';
          // ------------------------------------------------------------------ SIGNATURE UPLOAD
          if (isSignatureQuestion && question.signatureResponse != null) {
            final signatureImage = question.signatureResponse!;

            // Verifica se a assinatura precisa de upload (nao tem URL)
            if (signatureImage.bytes.isNotEmpty && (signatureImage.downloadUrl == null || signatureImage.downloadUrl!.isEmpty)) {
              final signatureName = '${taskModel.id}_${signatureImage.name}';
              final result = await uploadImage(signatureImage.copyWith(name: signatureName), taskModel.id, useTimeStamp: false);
              result.fold((exception) => throw RepositoryException(message: exception.message), (image) => question.signatureResponse = image);
            }
          }
          // ------------------------------------------------------------------ IMAGE UPLOAD
          final isImageQuestion = question.questionType == 'imagePickerInput';
          if (isImageQuestion && question.imagesResponse != null) {
            final List<ImageItemModel> currentImages = question.imagesResponse as List<ImageItemModel>;

            // Verifica se são imagens locais ou URL (Edição ou Novo)
            final localImages = currentImages.where((image) => image.bytes.isNotEmpty).toList();
            final existingUrls = currentImages.where((image) => image.downloadUrl != null && image.downloadUrl!.isNotEmpty).toList();
            // Separa as imagens novas para fazer upload
            final newImages = localImages.where((image) => image.downloadUrl == null || image.downloadUrl!.isEmpty).toList();

            final imageUploaded = await Future.wait(
              newImages.map((image) async {
                final result = await uploadImage(image, taskModel.id);
                return result.fold((exception) => throw RepositoryException(message: exception.message), (imageModel) => imageModel);
              }),
            );

            // Combina com URLs existentes
            final allImages = <ImageItemModel>[...imageUploaded, ...existingUrls];
            if (allImages.isNotEmpty) {
              question.imagesResponse = allImages;
            } else {
              question.imagesResponse = <ImageItemModel>[];
            }
          }
        }
      }
      // ------------------------------------------------------------------------------ CHANGE DATA
      if (newStatus != ActivityStatusEnum.inactive) {
        taskModel = taskModel.copyWith(activityStatus: newStatus);
      }
      final taskMap = taskModel.toJsonForFirebase();
      if (taskModel.id.isEmpty) taskMap.remove('id');
      final result = await _activityServices.onSave(taskMap);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao salvar tarefa: ${se.message}'));
        },
        (String taskId) async {
          await Future.wait(
            imagesToRemove.where((image) => image.fullPath != null && image.fullPath!.isNotEmpty).toList().map((image) async {
              final result = await _imageServices.deleteImage(image.fullPath!);
              return result.fold((ServiceException se) => throw RepositoryException(message: se.message), (Unit unit) => unit);
            }),
          );
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao tratar tarefa ${e.toString()}'));
    }
  }

  Future<Either<RepositoryException, Unit>> deleteTask(String id) async {
    try {
      final taskResult = await _activityServices.findOne(id);
      return await taskResult.fold(
        (ServiceException se) {
          return Left(RepositoryException(message: se.message));
        },
        (Map<String, dynamic> taskMap) async {
          if (ActivityStatusEnumExtension.fromString(taskMap['status']) != ActivityStatusEnum.inactive) {
            return Left(RepositoryException(message: 'não é possível deletar uma atividade ativa'));
          }
          // final result = await _activityServices.delete(id);
          // return result.fold(
          //   (ServiceException se) async {
          //     return Left(
          //       RepositoryException(message: 'Erro ao deletar o perfil: ${se.message}'),
          //     );
          //   },
          //   (Unit unit) async {
          //     return Right(unit);
          //   },
          // );
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao deletar o formulário ${e.toString()}'));
    }
  }

  Future<Either<RepositoryException, ImageItemModel>> uploadImage(ImageItemModel image, String taskId, {bool? useTimeStamp}) async {
    try {
      final result = await _imageServices.uploadImage(image, 'tasks/$taskId', maxWidth: 720, useTimeStamp: useTimeStamp ?? true);
      return result.fold(
        (ServiceException se) {
          return Left(RepositoryException(message: se.message));
        },
        (ImageItemModel imageModel) {
          return Right(imageModel);
        },
      );
    } catch (e) {
      log('Erro no repositório ao subir imagem ${e.toString()}');
      return Left(RepositoryException(message: 'Erro no repositório ao subir imagem ${e.toString()}'));
    }
  }
}
