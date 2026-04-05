import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/data/repositories/department/department_repository_impl.dart';
import 'package:versystems_app/data/repositories/profile/profile_repository_impl.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/data/services/company/company_services.dart';
import 'package:versystems_app/data/services/department/department_services_impl.dart';
import 'package:versystems_app/data/services/profile/profile_services_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';
import 'package:versystems_app/ui/modules/user_manager/user_form/user_form_view_model.dart';

class UserFormBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(DepartmentServicesImpl());
    autoPut(UserServicesImpl());
    autoLazyPut(
      DepartmentRepositoryImpl(
        departmentService: Get.find<DepartmentServicesImpl>(),
        userServices: Get.find<UserServicesImpl>(),
      ),
    );
    autoPut(ProfileServicesImpl());
    autoLazyPut(
      ProfileRepositoryImpl(
        profileServices: Get.find<ProfileServicesImpl>(),
        userServices: Get.find<UserServicesImpl>(),
      ),
    );
    // CompanyRepository para carregar lista de empresas no formulário de usuário
    autoPut(CompanyServices());
    autoLazyPut(
      CompanyRepositoryImpl(
        companyServices: Get.find<CompanyServices>(),
      ),
    );
    autoLazyPut(
      UserFormViewModel(
        userRepository: Get.find<UserRepositoryImpl>(),
        departmentRepository: Get.find<DepartmentRepositoryImpl>(),
        profileRespository: Get.find<ProfileRepositoryImpl>(),
        companyRepository: Get.find<CompanyRepositoryImpl>(),
      ),
    );
  }
}

