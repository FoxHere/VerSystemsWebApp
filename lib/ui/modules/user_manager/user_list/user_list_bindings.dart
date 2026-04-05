import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';
import 'package:versystems_app/ui/modules/user_manager/user_list/user_list_view_model.dart';


class UserListBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(UserServicesImpl());
    autoPut(UserServicesImpl());
    autoPut(
      UserListViewModel(userRepository: Get.find<UserRepositoryImpl>()),
      tag: 'depList',
    );
  }
}
