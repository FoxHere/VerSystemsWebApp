import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';

abstract interface class SettingsRepository {
  Future<Either<RepositoryException, Map<String, dynamic>>> findSettings();
}
