import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/activity/activity_repository_impl.dart';
import 'package:versystems_app/data/repositories/client/client_repository_impl.dart';
import 'package:versystems_app/data/repositories/formulary/formulary_repository_impl.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/data/services/client/client_services.dart';
import 'package:versystems_app/data/services/formulary/formulary_services.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_form/activity_manager_view_model.dart';

class ActivityManagerBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(ActivityServices());
    autoPut(FormularyServices());
    autoPut(ClientServices());
    autoPut(
      ActivityRepositoryImpl(
        activityServices: Get.find<ActivityServices>(),
      ),
    );
    autoPut(
      FormularyRepositoryImpl(
        formularyServices: Get.find<FormularyServices>(),
        activityServices: Get.find<ActivityServices>(),
      ),
    );
    autoPut(
      ClientRepositoryImpl(clientServices: Get.find<ClientServices>()),
    );
    autoPut(
      ActivityManagerViewModel(
        activityRepositoryImpl: Get.find<ActivityRepositoryImpl>(),
        formularyRepositoryImpl: Get.find<FormularyRepositoryImpl>(),
        userRepositoryImpl: Get.find<UserRepositoryImpl>(),
        clientRepositoryImpl: Get.find<ClientRepositoryImpl>(),
      ),
    );
  }
}
