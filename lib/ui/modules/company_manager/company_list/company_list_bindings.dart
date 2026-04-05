import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/data/services/company/company_services.dart';
import 'package:versystems_app/ui/modules/company_manager/company_list/company_list_view_model.dart';

class CompanyListBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(CompanyServices());
    autoLazyPut(
      CompanyRepositoryImpl(
        companyServices: Get.find<CompanyServices>(),
      ),
    );
    autoPut(
      CompanyListViewModel(
        companyRepository: Get.find<CompanyRepositoryImpl>(),
      ),
    );
  }
}
