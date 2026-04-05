
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/ui/modules/settings/settings_controller.dart';

class SettingsBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoLazyPut(SettingsController());
  }
}
