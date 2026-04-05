import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/services/auth/auth_services_impl.dart';
import 'package:versystems_app/data/services/department/department_services_impl.dart';
import 'package:versystems_app/data/services/profile/profile_services_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';
import 'package:versystems_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:versystems_app/ui/modules/login/login_view_model.dart';


class LoginBindigns extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(AuthServiceImpl());
    autoPut(UserServicesImpl());
    autoPut(DepartmentServicesImpl());
    autoPut(ProfileServicesImpl());
    autoPut(
      AuthRepositoryImpl(
        authServiceImp: Get.find<AuthServiceImpl>(),
        userServicesImpl: Get.find<UserServicesImpl>(),
        departmentServicesImpl: Get.find<DepartmentServicesImpl>(),
        profileServivesImpl: Get.find<ProfileServicesImpl>(),
      ),
    );
    autoLazyPut(LoginViewModel(authRepository: Get.find<AuthRepositoryImpl>()));
  }
}
