import 'package:versystems_app/config/helpers/routes/paths_helper.dart';

/// Helper class para gerenciar os menus disponíveis no sistema
/// Baseado no PathsHelper, na mesma ordem em que aparecem no sidebar.
class MenusHelper {
  /// Lista de menus disponíveis para controle de acesso (RBAC)
  /// Exclui rotas especiais como '/:id' e '/new'
  static const List<String> availableMenus = [
    PathsHelper.dashboard,
    PathsHelper.formularies,
    PathsHelper.activities,
    PathsHelper.tasks,
    PathsHelper.companies,
    PathsHelper.clients,
    PathsHelper.users,
    PathsHelper.profiles,
    PathsHelper.departments,
    PathsHelper.settings,
  ];

  /// Retorna um mapa com o nome amigável (em Português Brasileiro) de cada menu
  static Map<String, String> getMenuLabels() {
    return {
      PathsHelper.dashboard: 'Dashboard',
      PathsHelper.formularies: 'Formulários',
      PathsHelper.activities: 'Atividades',
      PathsHelper.tasks: 'Minhas Tarefas',
      PathsHelper.companies: 'Filiais',
      PathsHelper.clients: 'Clientes',
      PathsHelper.users: 'Usuários',
      PathsHelper.profiles: 'Perfis',
      PathsHelper.departments: 'Departamentos',
      PathsHelper.settings: 'Configurações',
    };
  }

  /// Retorna o nome amigável de um menu específico
  static String getMenuLabel(String menuPath) {
    return getMenuLabels()[menuPath] ?? menuPath;
  }
}

