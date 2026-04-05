import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/helpers/gen/assets.gen.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';

class SplashView extends StatefulWidget {
  final String? redirectTo;
  const SplashView({super.key, this.redirectTo});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await authController.initializeIt();
    if (!mounted) return;

    // Verifica se existe alguma empresa cadastrada
    final companyRepository = Get.find<CompanyRepositoryImpl>();
    final hasAnyResult = await companyRepository.hasAnyCompany();
    final hasCompany = hasAnyResult.fold((_) => true, (has) => has);

    if (!mounted) return;
    Get.put(true, tag: 'splashInitialized', permanent: true);
    Get.put(hasCompany, tag: 'hasCompany', permanent: true);

    if (!hasCompany) {
      context.go(RoutesHelper.setup);
      return;
    }
    context.go(widget.redirectTo ?? RoutesHelper.login);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Assets.images.common.logos.logo01.image(), Center(child: CircularProgressIndicator())],
      ),
    );
  }
}
