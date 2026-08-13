import 'package:get/get.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/gps_location_response_model.dart';
import 'package:versystems_app/data/repositories/location/location_repository.dart';

enum GpsLocationState {
  initial,
  loading,
  success,
  permissionDenied,
  locationUnavailable,
  error,
}

class GpsLocationViewModel extends GetxController {
  final LocationRepository _locationRepository;

  GpsLocationViewModel({LocationRepository? locationRepository})
      : _locationRepository = locationRepository ?? Get.find<LocationRepository>();

  final state = GpsLocationState.initial.obs;
  final locationData = Rxn<GpsLocationResponseModel>();
  final errorMessage = ''.obs;

  void initWithValue(GpsLocationResponseModel? initialValue) {
    if (initialValue != null) {
      locationData.value = initialValue;
      state.value = GpsLocationState.success;
    } else {
      state.value = GpsLocationState.initial;
    }
  }

  Future<void> fetchLocation({required Function(GpsLocationResponseModel) onLocationCaptured}) async {
    state.value = GpsLocationState.loading;
    errorMessage.value = '';

    final result = await _locationRepository.getCurrentLocation();

    result.fold(
      (RepositoryException exception) {
        final msg = exception.message.toLowerCase();
        if (msg.contains('negada') || msg.contains('permissão') || msg.contains('denied')) {
          state.value = GpsLocationState.permissionDenied;
        } else if (msg.contains('desativado') || msg.contains('indisponível') || msg.contains('unavailable')) {
          state.value = GpsLocationState.locationUnavailable;
        } else {
          state.value = GpsLocationState.error;
        }
        errorMessage.value = exception.message;
      },
      (GpsLocationResponseModel location) {
        locationData.value = location;
        state.value = GpsLocationState.success;
        onLocationCaptured(location);
      },
    );
  }
}
