import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/gps_location_response_model.dart';
import 'package:versystems_app/data/repositories/location/location_repository.dart';
import 'package:versystems_app/data/services/location/location_services.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationServices _locationServices;

  LocationRepositoryImpl({required LocationServices locationServices})
      : _locationServices = locationServices;

  @override
  Future<Either<RepositoryException, GpsLocationResponseModel>> getCurrentLocation() async {
    try {
      final result = await _locationServices.getCurrentLocation();
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (GpsLocationResponseModel location) {
          return Right(location);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório de localização: ${e.toString()}'));
    }
  }
}
