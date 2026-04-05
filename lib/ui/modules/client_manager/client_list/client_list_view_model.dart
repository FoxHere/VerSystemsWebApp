import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/repositories/client/client_repository_impl.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';

class ClientListViewModel extends BaseViewModel with MessageStateMixin {
  final ClientRepositoryImpl _clientRepository;
  final CompanyRepositoryImpl _companyRepository;

  ClientListViewModel({required ClientRepositoryImpl clientRepository, required CompanyRepositoryImpl companyRepository})
    : _clientRepository = clientRepository,
      _companyRepository = companyRepository;

  final clients = RxList<ClientModel>();
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final companies = RxList<CompanyModel>();
  @override
  void onInit() {
    super.onInit();
    findAllClients({});
    findAllCompanies({});
  }

  Future<void> findAllClients(Map<String, dynamic> filters) async {
    pageStatus.value = PageStatusLoading();
    final result = await _clientRepository.findAllClients(filters);
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (List<ClientModel> clientList) {
        if (clientList.isEmpty) {
          pageStatus.value = PageStatusEmpty(title: 'Não existem clientes cadastrados');
        }
        clients.assignAll(clientList);
        pageStatus.value = PageStatusSuccess<RxList<ClientModel>>(clients);
      },
    );
  }

  Future<void> deleteClient(String id) async {
    final result = await _clientRepository.deleteClient(id);
    result.fold(
      (exception) {
        showError('Erro ao deletar cliente: ${exception.message}');
      },
      (unit) {
        showSuccess('Cliente deletado com sucesso!');
        clients.removeWhere((client) => client.id == id);
        clients.refresh();
        update();
      },
    );
  }

  Future<void> findAllCompanies(Map<String, dynamic> filters) async {
    final result = await _companyRepository.findAllCompanies(filters);
    result.fold(
      (exception) {
        showError('Erro ao buscar empresas: ${exception.message}');
      },
      (List<CompanyModel> companyList) {
        companies.assignAll(companyList);
      },
    );
  }
}
