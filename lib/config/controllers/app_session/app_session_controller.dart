import 'package:get/get.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_list/activity_list_view_model.dart';
import 'package:versystems_app/ui/modules/client_manager/client_list/client_list_view_model.dart';
import 'package:versystems_app/ui/modules/dashboard/dashboard_view_model.dart';
import 'package:versystems_app/ui/modules/department_manager/department_list/department_list_view_model.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_list/form_list_view_model.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_list/profile_list_view_model.dart';
import 'package:versystems_app/ui/modules/task_manager/task_list/task_list_view_model.dart';
import 'package:versystems_app/ui/modules/user_manager/user_list/user_list_view_model.dart';

/// Controlador de sessão do aplicativo.
///
/// Armazena o [companyId] da branch/empresa do usuário logado.
/// Todos os serviços do Firebase devem usar [AppSessionController.instance.companyId]
/// em vez de [Env.companyId] para garantir o funcionamento multi-tenant.
class AppSessionController extends GetxController {
  static AppSessionController get instance => Get.find<AppSessionController>();

  final _companyId = ''.obs;

  /// ID da empresa/branch ativa na sessão atual.
  String get companyId => _companyId.value;

  /// Define o companyId da sessão (chamado durante o login ou troca de filial).
  void setCompanyId(String id) {
    _companyId.value = id;
  }

  /// Limpa cache de ViewModels registrados no GetX para garantir que todos os módulos
  /// recarreguem os dados do zero com a nova filial selecionada.
  void clearModuleCache() {
    Get.delete<FormListViewModel>(force: true);
    Get.delete<ActivityListViewModel>(force: true);
    Get.delete<TaskListViewModel>(force: true);
    Get.delete<ClientListViewModel>(force: true);
    Get.delete<DepartmentListViewModel>(force: true);
    Get.delete<ProfileListViewModel>(force: true);
    Get.delete<UserListViewModel>(force: true);
    Get.delete<DashboardViewModel>(force: true);
  }

  /// Limpa a sessão (chamado no logout).
  void clearSession() {
    clearModuleCache();
    _companyId.value = '';
  }

  /// Retorna true se houver uma sessão ativa com companyId definido.
  bool get hasSession => _companyId.value.isNotEmpty;
}
