import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';

abstract interface class ProfileRepository {
  Future<Either<RepositoryException, ProfileModel?>> findOneById(String id);
  Future<Either<RepositoryException, List<ProfileModel>>> findAllProfiles(
    Map<String, dynamic> filters,
  );
  Future<Either<RepositoryException, String>> saveProfile(ProfileModel profileModel);
  Future<Either<RepositoryException, Unit>> deleteProfile(String id);
}
