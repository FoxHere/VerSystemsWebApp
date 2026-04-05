import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/ui/modules/home/home_view_model.dart';
import 'package:versystems_app/ui/shared/sidebar/sidebar_controller.dart';


class HomeBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(SidebarController());
    autoLazyPut(HomeViewModel());
  }
}
