import 'package:get/get.dart';

/// Controlador de sessão do aplicativo.
///
/// Armazena o [companyId] da branch/empresa do usuário logado.
/// Todos os serviços do Firebase devem usar [AppSessionController.instance.companyId]
/// em vez de [Env.companyId] para garantir o funcionamento multi-tenant.
class AppSessionController extends GetxController {
  static AppSessionController get instance => Get.find();

  final _companyId = ''.obs;

  /// ID da empresa/branch ativa na sessão atual.
  String get companyId => _companyId.value;

  /// Define o companyId da sessão (chamado durante o login).
  void setCompanyId(String id) {
    _companyId.value = id;
  }

  /// Limpa a sessão (chamado no logout).
  void clearSession() {
    _companyId.value = '';
  }

  /// Retorna true se houver uma sessão ativa com companyId definido.
  bool get hasSession => _companyId.value.isNotEmpty;
}
