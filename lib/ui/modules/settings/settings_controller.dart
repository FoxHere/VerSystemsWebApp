import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/controllers/theme/theme_controller.dart';
import 'package:versystems_app/data/models/user/user_settings_model.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';

class SettingsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final UserRepositoryImpl userRepository = Get.find<UserRepositoryImpl>();
  final ThemeController themeController = Get.find<ThemeController>();

  final themeMode = AppThemeMode.system.obs;
  final notificationsEnabled = true.obs;
  final language = 'pt_BR'.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final user = authController.localUserModel.value;
    if (user != null) {
      themeMode.value = user.settings.themeMode;
      notificationsEnabled.value = user.settings.notificationsEnabled;
      language.value = user.settings.language;
    }
  }

  void toggleThemeMode() {
    if (themeMode.value == AppThemeMode.light || themeMode.value == AppThemeMode.system) {
      themeMode.value = AppThemeMode.dark;
    } else {
      themeMode.value = AppThemeMode.light;
    }

    // Also toggle the actual theme in the app
    themeController.toggleThemeMode();

    _saveSettings();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    final user = authController.localUserModel.value;
    if (user != null) {
      isLoading.value = true;
      final newSettings = UserSettingsModel(themeMode: themeMode.value, notificationsEnabled: notificationsEnabled.value, language: language.value);
      final updatedUser = user.copyWith(settings: newSettings);

      await authController.updateLocalUser(updatedUser);
      final result = await userRepository.saveUser(userModel: updatedUser);

      result.fold(
        (l) {
          // You could show a toast here if save fails
        },
        (r) {
          // success
        },
      );
      isLoading.value = false;
    }
  }
}
