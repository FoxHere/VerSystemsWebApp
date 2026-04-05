import 'package:get/get.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/ui/modules/company_manager/company_list/company_list_view_model.dart';

class CompanyManagerViewModel extends BaseViewModel with MessageStateMixin {
  final CompanyRepositoryImpl _companyRepositoryImpl;
  final CompanyListViewModel companyListViewModel = Get.find<CompanyListViewModel>();

  CompanyManagerViewModel({required CompanyRepositoryImpl companyRepositoryImpl}) : _companyRepositoryImpl = companyRepositoryImpl;

  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final companyModel = Rx<CompanyModel>(CompanyModel.empty());

  void initialize(String companyId) async {
    pageStatus.value = PageStatusLoading();

    await Future.delayed(const Duration(seconds: 1));
    if (companyId != 'new') {
      if (companyListViewModel.companies.isEmpty) {
        await companyListViewModel.findAllCompanies({});
      }
      final matchingCompany = companyListViewModel.companies.firstWhereOrNull((company) => company.id == companyId);
      if (matchingCompany != null) {
        companyModel.value = matchingCompany;
        pageStatus.value = PageStatusSuccess<CompanyModel>(companyModel.value);
      } else {
        showError('Empresa não encontrada');
        pageStatus.value = PageStatusError('Empresa não encontrada');
      }
      return;
    } else {
      pageStatus.value = PageStatusSuccess<CompanyModel>(companyModel.value);
      return;
    }
  }

  Future<void> onSaveCompany(CompanyModel companyForm) async {
    try {
      pageStatus.value = PageStatusLoading();
      final company = companyForm.copyWith(createdAt: companyForm.createdAt ?? DateTime.now(), updatedAt: DateTime.now());
      await Future.delayed(const Duration(seconds: 2));

      final result = await _companyRepositoryImpl.saveCompany(company);
      result.fold(
        (RepositoryException re) {
          showError(re.message);
        },
        (String companyId) {
          if (companyForm.id != '') {
            final index = companyListViewModel.companies.indexWhere((company) => company.id == companyForm.id);
            if (index != -1) companyListViewModel.companies[index] = company;
            companyListViewModel.companies.refresh();
          } else {
            companyListViewModel.companies.insert(0, company.copyWith(id: companyId));
          }
          showSuccess('Empresa salva com sucesso');
          pageStatus.value = PageStatusSuccess<CompanyModel>(company);
        },
      );
    } catch (e) {
      showError('Erro ao salvar empresa');
    }
  }
}
