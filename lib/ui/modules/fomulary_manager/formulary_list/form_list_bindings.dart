import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/formulary/formulary_repository_impl.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/data/services/formulary/formulary_services.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_list/form_list_view_model.dart';


class FormListBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(FormularyServices());
    autoPut(ActivityServices());
    autoPut(ImageServices());
    autoPut(
      FormularyRepositoryImpl(
        formularyServices: Get.find<FormularyServices>(),
        activityServices: Get.find<ActivityServices>(),
      ),
    );
    autoPut(FormListViewModel(Get.find<FormularyRepositoryImpl>()));
  }
}
