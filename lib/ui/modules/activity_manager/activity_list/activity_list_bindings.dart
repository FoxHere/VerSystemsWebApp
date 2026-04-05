import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/activity/activity_repository_impl.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_list/activity_list_view_model.dart';

class ActivityListBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(ActivityServices());
    autoLazyPut(
      ActivityRepositoryImpl(
        activityServices: Get.find<ActivityServices>(),
      ),
    );
    autoPut(ActivityListViewModel(activityRepository: Get.find<ActivityRepositoryImpl>()));
  }
}
