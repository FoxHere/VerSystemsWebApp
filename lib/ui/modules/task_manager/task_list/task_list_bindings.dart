import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/task/task_repository_impl.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_functions_service.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/modules/task_manager/task_list/task_list_view_model.dart';


class TaskListBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(ActivityServices());
    autoPut(ImageServices());
    autoPut(
      TaskRepositoryImpl(
        dashboardFunctionsService: Get.find<DashboardFunctionsServiceImpl>(),
        activityServices: Get.find<ActivityServices>(),
        imageServices: Get.find<ImageServices>(),
      ),
    );
    autoPut(TaskListViewModel(taskRepositoryImpl: Get.find<TaskRepositoryImpl>()));
  }
}
