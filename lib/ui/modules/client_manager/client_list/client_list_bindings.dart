import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/client/client_repository_impl.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/data/services/client/client_services.dart';
import 'package:versystems_app/data/services/company/company_services.dart';
import 'package:versystems_app/data/services/settings/settings_services_impl.dart';
import 'package:versystems_app/ui/modules/client_manager/client_list/client_list_view_model.dart';

class ClientListBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(ClientServices());
    autoLazyPut(
      ClientRepositoryImpl(
        clientServices: Get.find<ClientServices>(),
      ),
    );
    autoPut(CompanyServices());
    autoLazyPut(
      CompanyRepositoryImpl(
        companyServices: Get.find<CompanyServices>(),
        settingsServices: Get.find<SettingsServicesImpl>(),
      ),
    );
    autoPut(
      ClientListViewModel(
        clientRepository: Get.find<ClientRepositoryImpl>(),
        companyRepository: Get.find<CompanyRepositoryImpl>(),
      ),
    );
  }
}
