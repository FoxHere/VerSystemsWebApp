import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/services/department/department_services_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';
import 'package:versystems_app/data/repositories/department/department_repository_impl.dart';
import 'package:versystems_app/ui/modules/department_manager/department_form/department_form_view_model.dart';

class DepartmentFormBindings extends AutoDisposeBindings {
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
    autoLazyPut(
      DepartmentFormViewModel(
        departmentRepository: Get.find<DepartmentRepositoryImpl>(),
      ),
    );
  }
}
