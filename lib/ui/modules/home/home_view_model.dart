import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/data/models/sidebar/sidebar_item_model.dart';
import 'package:versystems_app/data/repositories/settings/settings_repository_impl.dart';

class HomeViewModel extends GetxController with MessageStateMixin {
  final SettingsRepositoryImpl settingsRepository;

  final isLoading = false.obs;

  HomeViewModel({required this.settingsRepository});
  final authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    List<MenuItemModel?> items = [];
    isLoading(true);
    try {
      await settingsRepository.findSettings().then(
        (result) => result.fold((exception) {
          showError(exception.message);
        }, (settings) {}),
      );
    } finally {
      isLoading(false);
    }
  }
}
