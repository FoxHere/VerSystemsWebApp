import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/theme/theme_controller.dart';
import 'package:versystems_app/config/routes/gorouter_routes.dart';
import 'package:versystems_app/config/utils/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kIsWeb) {
  //   usePathUrlStrategy();
  // }
  await initDependencies();
  runApp(const VerSystemsApp());
}

class VerSystemsApp extends StatelessWidget {
  const VerSystemsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() {
      return ShadcnApp.router(
        debugShowCheckedModeBanner: false,
        title: 'VerSystems Platform',
        theme: ThemeData(
          colorScheme: themeController.isDarkMode ? ColorSchemes.darkSlate.violet : ColorSchemes.lightNeutral.violet,
          surfaceOpacity: 0.7,
          surfaceBlur: 8.0,
        ),
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      );
    });
  }
}
