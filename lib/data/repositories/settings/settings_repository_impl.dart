

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/repositories/settings/settings_repository.dart';
import 'package:versystems_app/data/services/settings/settings_services.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsServices settingsServices;
  SettingsRepositoryImpl({required this.settingsServices});

  @override
  Future<Either<RepositoryException, Map<String, dynamic>>> findSettings() async {
    final result = await settingsServices.findSettings();
    return await result.fold(
      (exception) {
        return Left(RepositoryException(message: exception.message));
      },
      (settings) {
        return Right(settings);
      },
    );
    // return Right(jsonDecode(await rootBundle.loadString('assets/files/menu_schema.json')));
  }
}
