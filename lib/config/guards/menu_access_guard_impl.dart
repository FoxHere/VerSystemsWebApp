import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/guards/route_guard.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';

/// Guard que verifica se o usuário tem acesso à rota baseado nos menus permitidos (allowedMenus)
/// do perfil do usuário. Se não tiver acesso, redireciona para o dashboard.
class MenuAccessGuardImpl implements RouteGuard {
  MenuAccessGuardImpl();

  @override
  String? call(GoRouterState state) {
    final authController = Get.find<AuthController>();
    final localUserModel = authController.localUserModel.value;

    // Se não houver usuário autenticado, deixa o AuthGuard lidar com isso
    if (localUserModel == null) {
      return null;
    }

    // Obtém os menus permitidos do perfil do usuário
    final allowedMenus = localUserModel.profile.allowedMenus;

    // Obtém a rota atual (sem parâmetros de query)
    final currentRoute = state.matchedLocation.split('?').first;

    // Se não houver menus permitidos, bloqueia o acesso (exceto se já estiver no dashboard)
    if (allowedMenus.isEmpty) {
      // Se já estiver no dashboard, permite o acesso
      if (currentRoute.startsWith(RoutesHelper.dashboard)) {
        return null;
      }
      // Caso contrário, redireciona para o dashboard
      return RoutesHelper.dashboard;
    }

    // Verifica se a rota atual está nos menus permitidos
    // Também verifica rotas filhas (ex: /activities/:id deve permitir se /activities estiver permitido)
    final hasAccess = allowedMenus.any((menu) {
      // Verifica se a rota atual começa com o menu permitido
      return currentRoute.startsWith(menu) || menu == currentRoute;
    });

    // Se não tiver acesso, verifica se está tentando acessar o dashboard
    if (!hasAccess) {
      // Se já estiver no dashboard, permite o acesso (fallback)
      if (currentRoute.startsWith(RoutesHelper.dashboard)) {
        return null;
      }
      // Verifica se o dashboard está nos menus permitidos antes de redirecionar
      final hasDashboardAccess = allowedMenus.any((menu) {
        return menu == RoutesHelper.dashboard || RoutesHelper.dashboard.startsWith(menu);
      });
      
      // Se tiver acesso ao dashboard, redireciona para ele
      if (hasDashboardAccess) {
        return RoutesHelper.dashboard;
      }
      // Se não tiver acesso ao dashboard, redireciona para o primeiro menu permitido
      return allowedMenus.first;
    }

    return null;
  }
}

