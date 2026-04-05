import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/guards/route_guard.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';


class AuthGuardImpl implements RouteGuard {
  AuthGuardImpl({this.invert = false});

  final bool invert;

  @override
  String? call(GoRouterState state) {
    final authController = Get.find<AuthController>();
    if (!authController.isInitialized.value && !invert) {
      return '${RoutesHelper.login}?redirectTo=${state.matchedLocation}';
    } else if (authController.isInitialized.value && invert) {
      return RoutesHelper.dashboard;
    }
    return null;
  }
}
