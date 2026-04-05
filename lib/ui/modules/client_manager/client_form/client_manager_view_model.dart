import 'package:get/get.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/data/models/client/client_status.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/client/client_address_model.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/data/repositories/client/client_repository_impl.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/ui/modules/client_manager/client_list/client_list_view_model.dart';

class ClientManagerViewModel extends BaseViewModel with MessageStateMixin {
  final ClientRepositoryImpl _clientRepositoryImpl;
  final ClientListViewModel clientListViewModel = Get.find<ClientListViewModel>();

  ClientManagerViewModel({required ClientRepositoryImpl clientRepositoryImpl, required CompanyRepositoryImpl companyRepositoryImpl})
    : _clientRepositoryImpl = clientRepositoryImpl;

  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final clientModel = Rx<ClientModel>(
    ClientModel(
      id: '',
      name: '',
      email: '',
      phone: '',
      clientStatus: ClientStatusEnum.active,
      clientType: ClientType.physical,
      addresses: [ClientAddressModel.empty()],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  void initialize(String clientId) async {
    pageStatus.value = PageStatusLoading();

    await Future.delayed(const Duration(seconds: 1));
    if (clientId != 'new') {
      if (clientListViewModel.clients.isEmpty) {
        await clientListViewModel.findAllClients({});
      }
      final matchingClient = clientListViewModel.clients.firstWhereOrNull((client) => client.id == clientId);
      if (matchingClient != null) {
        clientModel.value = matchingClient;
        pageStatus.value = PageStatusSuccess<ClientModel>(clientModel.value);
      } else {
        showError('Cliente não encontrado');
        pageStatus.value = PageStatusError('Cliente não encontrado');
      }
      return;
    } else {
      pageStatus.value = PageStatusSuccess<ClientModel>(clientModel.value);
      return;
    }
  }

  Future<void> onSaveClient(ClientModel clientForm) async {
    try {
      pageStatus.value = PageStatusLoading();
      final client = clientForm.copyWith(createdAt: clientForm.createdAt ?? DateTime.now(), updatedAt: DateTime.now());
      await Future.delayed(const Duration(seconds: 2));

      final result = await _clientRepositoryImpl.saveClient(client);
      result.fold(
        (RepositoryException re) {
          showError(re.message);
        },
        (String clientId) {
          if (clientForm.id != '') {
            final index = clientListViewModel.clients.indexWhere((client) => client.id == clientForm.id);
            if (index != -1) clientListViewModel.clients[index] = client;
            clientListViewModel.clients.refresh();
          } else {
            clientListViewModel.clients.insert(0, client.copyWith(id: clientId));
          }
          showSuccess('Cliente salvo com sucesso');
          pageStatus.value = PageStatusSuccess<ClientModel>(client);
        },
      );
    } catch (e) {
      showError('Erro ao salvar cliente');
    }
  }
}
