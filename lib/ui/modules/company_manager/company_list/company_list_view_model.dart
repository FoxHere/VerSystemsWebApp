import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';

class CompanyListViewModel extends BaseViewModel with MessageStateMixin {
  final CompanyRepositoryImpl _companyRepository;

  CompanyListViewModel({required CompanyRepositoryImpl companyRepository}) : _companyRepository = companyRepository;

  final companies = RxList<CompanyModel>();
  final pageStatus = Rx<PageStatus>(PageStatusIdle());

  @override
  void onInit() {
    super.onInit();
    findAllCompanies({});
  }

  Future<void> findAllCompanies(Map<String, dynamic> filters) async {
    pageStatus.value = PageStatusLoading();
    final result = await _companyRepository.findAllCompanies(filters);
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (List<CompanyModel> companyList) {
        if (companyList.isEmpty) {
          pageStatus.value = PageStatusEmpty(title: 'Não existem empresas cadastradas');
        }
        companies.assignAll(companyList);
        pageStatus.value = PageStatusSuccess<RxList<CompanyModel>>(companies);
      },
    );
  }

  Future<void> deleteCompany(String id) async {
    final result = await _companyRepository.deleteCompany(id);
    result.fold(
      (exception) {
        showError('Erro ao deletar empresa: ${exception.message}');
      },
      (unit) {
        showSuccess('Empresa deletada com sucesso!');
        companies.removeWhere((company) => company.id == id);
        companies.refresh();
        update();
      },
    );
  }
}
