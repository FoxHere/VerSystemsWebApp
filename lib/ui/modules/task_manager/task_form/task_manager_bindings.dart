import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/repositories/task/task_repository_impl.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_functions_service.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/components/report/report_view_model.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/task_manager_view_model.dart';


class TaskManagerBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(ActivityServices());
    autoPut(ImageServices());
    autoPut(ReportViewModel<ActivityModel>());
    autoPut(
      TaskRepositoryImpl(
        dashboardFunctionsService: Get.find<DashboardFunctionsServiceImpl>(),
        activityServices: Get.find<ActivityServices>(),
        imageServices: Get.find<ImageServices>(),
      ),
    );
    autoPut(TaskManagerViewModel(taskRepositoryImpl: Get.find<TaskRepositoryImpl>()));
  }
}
