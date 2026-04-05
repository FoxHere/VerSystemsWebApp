
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';

abstract interface class SettingsServices {
  Future<Either<ServiceException, Map<String, dynamic>>> findSettings();
}
