import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/client/client_repository_impl.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/data/services/client/client_services.dart';
import 'package:versystems_app/data/services/company/company_services.dart';
import 'package:versystems_app/ui/modules/client_manager/client_form/client_manager_view_model.dart';

class ClientManagerBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(ClientServices());
    autoPut(CompanyServices());
    autoLazyPut(
      ClientRepositoryImpl(
        clientServices: Get.find<ClientServices>(),
      ),
    );
    autoLazyPut(
      CompanyRepositoryImpl(
        companyServices: Get.find<CompanyServices>(),
      ),
    );
    autoPut(
      ClientManagerViewModel(
        clientRepositoryImpl: Get.find<ClientRepositoryImpl>(),
        companyRepositoryImpl: Get.find<CompanyRepositoryImpl>(),
      ),
    );
  }
}
