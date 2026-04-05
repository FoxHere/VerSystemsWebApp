import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/ui/modules/user_profile/user_profile_view_model.dart';


class UserProfileBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoLazyPut(
      UserProfileViewModel(
        userRepository: Get.find<UserRepositoryImpl>(),
        authController: Get.find<AuthController>(),
      ),
    );
  }
}
