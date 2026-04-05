import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/dashboard/dashboard_repository_impl.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_functions_service.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_services_impl.dart';
import 'package:versystems_app/ui/modules/dashboard/dashboard_view_model.dart';


class DashboardBindigns extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(DashboardServicesImpl());
    autoPut(
      DashboardRepositoryImpl(
        dashBoardServices: Get.find<DashboardServicesImpl>(),
        dashboardFunctionsService: Get.find<DashboardFunctionsServiceImpl>(),
      ),
    );
    autoPut(DashboardViewModel(dashboardRepository: Get.find<DashboardRepositoryImpl>()));
  }
}
