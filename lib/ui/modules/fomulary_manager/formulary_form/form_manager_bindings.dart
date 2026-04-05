import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/formulary/formulary_repository_impl.dart';
import 'package:versystems_app/data/services/formulary/formulary_services.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/form_manager_view_model.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';


class FormManagerBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoLazyPut(FormularyServices());
    autoPut(ActivityServices());
    autoLazyPut(
      FormularyRepositoryImpl(
        formularyServices: Get.find<FormularyServices>(),
        activityServices: Get.find<ActivityServices>(),
      ),
    );
    autoPut(
      FormManagerViewModel(formManagerRepository: Get.find<FormularyRepositoryImpl>()),
    );
  }
}
