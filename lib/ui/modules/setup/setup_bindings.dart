import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/data/repositories/department/department_repository_impl.dart';
import 'package:versystems_app/data/repositories/profile/profile_repository_impl.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/data/services/department/department_services_impl.dart';
import 'package:versystems_app/data/services/profile/profile_services_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';
import 'package:versystems_app/ui/modules/setup/setup_view_model.dart';

class SetupBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    // DepartmentRepositoryImpl para criar o departamento padrão
    autoLazyPut(DepartmentRepositoryImpl(departmentService: Get.find<DepartmentServicesImpl>(), userServices: Get.find<UserServicesImpl>()));

    // ProfileRepositoryImpl para criar o perfil padrão
    autoLazyPut(ProfileRepositoryImpl(profileServices: Get.find<ProfileServicesImpl>(), userServices: Get.find<UserServicesImpl>()));

    autoPut(
      SetupViewModel(
        companyRepository: Get.find<CompanyRepositoryImpl>(),
        departmentRepository: Get.find<DepartmentRepositoryImpl>(),
        profileRepository: Get.find<ProfileRepositoryImpl>(),
        userRepository: Get.find<UserRepositoryImpl>(),
        appSessionController: Get.find<AppSessionController>(),
      ),
    );
  }
}
