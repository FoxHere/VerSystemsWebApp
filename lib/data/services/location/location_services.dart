import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/gps_location_response_model.dart';

class LocationServices {
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      log('Erro ao verificar serviço de localização: ${e.toString()}');
      return false;
    }
  }

  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      log('Erro ao verificar permissão de localização: ${e.toString()}');
      return LocationPermission.denied;
    }
  }

  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      log('Erro ao solicitar permissão de localização: ${e.toString()}');
      return LocationPermission.denied;
    }
  }

  Future<Either<ServiceException, GpsLocationResponseModel>> getCurrentLocation() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(
          ServiceException(
            message: 'O serviço de localização (GPS) está desativado no navegador/dispositivo.',
          ),
        );
      }

      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(
            ServiceException(
              message: 'Permissão de acesso à localização foi negada pelo usuário.',
            ),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(
          ServiceException(
            message:
                'Permissão de localização negada permanentemente. Permita o acesso à localização nas configurações do seu navegador.',
          ),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final locationModel = GpsLocationResponseModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        capturedAt: position.timestamp,
      );

      return Right(locationModel);
    } catch (e) {
      log('Erro ao obter localização: ${e.toString()}');
      return Left(
        ServiceException(
          message: 'Falha ao capturar a localização GPS: ${e.toString()}',
        ),
      );
    }
  }
}
