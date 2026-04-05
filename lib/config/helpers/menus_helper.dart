import 'package:versystems_app/config/helpers/routes/paths_helper.dart';

/// Helper class para gerenciar os menus disponíveis no sistema
/// Baseado no PathsHelper, excluindo rotas especiais como 'id' e 'new'
class MenusHelper {
  /// Lista de menus disponíveis para controle de acesso (RBAC)
  /// Exclui rotas especiais como '/:id' e '/new'
  static const List<String> availableMenus = [
    PathsHelper.dashboard,
    PathsHelper.activities,
    PathsHelper.settings,
    PathsHelper.formularies,
    PathsHelper.tasks,
    PathsHelper.profiles,
    PathsHelper.departments,
    PathsHelper.users,
    PathsHelper.clients,
    PathsHelper.companies,
  ];

  /// Retorna um mapa com o nome amigável de cada menu
  static Map<String, String> getMenuLabels() {
    return {
      PathsHelper.dashboard: 'Dashboard',
      PathsHelper.activities: 'Gerenciamento de Atividades',
      PathsHelper.settings: 'Configurações do sistema',
      PathsHelper.formularies: 'Gerenciamento de Formulários',
      PathsHelper.tasks: 'Gerenciamento de Tarefas',
      PathsHelper.profiles: 'Gerenciamento de Perfis',
      PathsHelper.departments: 'Gerenciamento de Departamentos',
      PathsHelper.users: 'Gerenciamento de Usuários',
      PathsHelper.clients: 'Gerenciamento de Clientes',
      PathsHelper.companies: 'Gerenciamento de Empresas',
    };
  }

  /// Retorna o nome amigável de um menu específico
  static String getMenuLabel(String menuPath) {
    return getMenuLabels()[menuPath] ?? menuPath;
  }
}
