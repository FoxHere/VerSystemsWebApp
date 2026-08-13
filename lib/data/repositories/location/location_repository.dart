import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/gps_location_response_model.dart';

abstract interface class LocationRepository {
  Future<Either<RepositoryException, GpsLocationResponseModel>> getCurrentLocation();
}
