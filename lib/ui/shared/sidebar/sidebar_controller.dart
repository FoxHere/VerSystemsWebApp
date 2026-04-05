import 'package:get/get.dart';

class SidebarController extends GetxController {
  var expandedMenu = ''.obs;

  void setExpandedMenu(String menuItem) {
    if (expandedMenu.value == menuItem) {
      expandedMenu.value = '';
    } else {
      expandedMenu.value = menuItem;
    }
  }
}
