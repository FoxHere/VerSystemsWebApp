

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/data/repositories/profile/profile_repository.dart';
import 'package:versystems_app/data/services/profile/profile_services.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileServices _profileServices;
  final UserServicesImpl _userServices;

  ProfileRepositoryImpl({
    required ProfileServices profileServices,
    required UserServicesImpl userServices,
  }) : _profileServices = profileServices,
       _userServices = userServices;

  @override
  Future<Either<RepositoryException, ProfileModel?>> findOneById(String id) async {
    try {
      final result = await _profileServices.findOne(id);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (Map<String, dynamic> profileData) {
          if (profileData.isEmpty) return Right(null);
          final profileModel = ProfileModel.fromJson(profileData);
          return Right(profileModel);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório, erro: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, List<ProfileModel>>> findAllProfiles(
    Map<String, dynamic> filters,
  ) async {
    try {
      final result = await _profileServices.findAll(filters: filters);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (List<Map<String, dynamic>> profiles) {
          if (profiles.isEmpty) return Right(<ProfileModel>[]);
          final profileModelList = profiles
              .map((profileMap) => ProfileModel.fromJson(profileMap))
              .toList();

          return Right(profileModelList);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório, erro: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, String>> saveProfile(ProfileModel profileModel) async {
    try {
      final profileMap = profileModel.toJsonForFirebase();
      if (profileModel.id.isEmpty) profileMap.remove('id');
      final result = await _profileServices.onSave(profileMap);
      return result.fold(
        (ServiceException se) {
          return Left(RepositoryException(message: 'Erro ao salvar o perfil: ${se.message}'));
        },
        (String profileId) {
          return Right(profileId);
        },
      );
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao tratar o perfil ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> deleteProfile(String id) async {
    try {
      final usersResult = await _userServices.findByProfile(id);
      return await usersResult.fold(
        (ServiceException se) {
          return Left(RepositoryException(message: se.message));
        },
        (List<Map<String, dynamic>> users) async {
          if (users.isNotEmpty) {
            return Left(RepositoryException(message: 'Há usuários vinculados ao perfil'));
          }
          final result = await _profileServices.delete(id);
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
        RepositoryException(message: 'Erro no repositório ao deletar o perfil ${e.toString()}'),
      );
    }
  }
}
