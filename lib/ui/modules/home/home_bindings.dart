import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/settings/settings_repository_impl.dart';
import 'package:versystems_app/data/services/settings/settings_services_impl.dart';
import 'package:versystems_app/ui/modules/home/home_view_model.dart';
import 'package:versystems_app/ui/shared/sidebar/sidebar_controller.dart';


class HomeBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(SidebarController());
    autoPut(SettingsServicesImpl());
    autoPut(SettingsRepositoryImpl(settingsServices: Get.find<SettingsServicesImpl>()));
    autoLazyPut(HomeViewModel(settingsRepository: Get.find<SettingsRepositoryImpl>()));
  }
}
