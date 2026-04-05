import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/gen/assets.gen.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/ui/modules/setup/components/setup_stepper.dart';
import 'package:versystems_app/ui/modules/setup/components/step_admin_user_form.dart';
import 'package:versystems_app/ui/modules/setup/components/step_company_form.dart';
import 'package:versystems_app/ui/modules/setup/setup_view_model.dart';

class SetupView extends StatefulWidget {
  const SetupView({super.key});

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> with MessageViewMixin, ResponsiveDeviceMixin {
  final SetupViewModel viewModel = Get.find<SetupViewModel>();

  final _stepCompanyKey = GlobalKey<StepCompanyFormState>();
  final _stepAdminKey = GlobalKey<StepAdminUserFormState>();
  final StepperController _steperController = StepperController();

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
  }

  void _onNext() {
    if (viewModel.currentStep.value == 0) {
      final isValid = _stepCompanyKey.currentState?.validateForm() ?? false;
      if (isValid) {
        viewModel.nextStep();
        _steperController.nextStep();
      }
    }
  }

  Future<void> _onFinish() async {
    final isValid = _stepAdminKey.currentState?.validateForm() ?? false;
    if (!isValid) return;

    final CompanyModel company = _stepCompanyKey.currentState?.companyModel ?? CompanyModel.empty();
    final UserModel admin = _stepAdminKey.currentState?.userModel ?? UserModel.empty();

    final success = await viewModel.saveAll(company: company, adminUser: admin);
    if (success && mounted) {
      context.go(RoutesHelper.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    final theme = Theme.of(context);
    final formHeight = MediaQuery.of(context).size.height - 150;
    return Scaffold(
      child: Row(
        children: [
          // ------------------------------------------------------------------Left branding panel
          if (isLargeScreen)
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Assets.images.common.logos.logo02.image(width: 180, fit: BoxFit.contain),
                    const SizedBox(height: 40),
                    Text(
                      'Bem-vindo à\nVerSystems Platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32),
                    ).h1,
                    const SizedBox(height: 16),
                    Text(
                      'Configure sua empresa e crie o\n'
                      'usuário administrador para começar.',
                      textAlign: TextAlign.center,
                    ).base,
                    const SizedBox(height: 48),
                    Column(
                      crossAxisAlignment: .start,
                      spacing: 16,
                      children: [
                        _InfoItem(
                          icon: Symbols.business,
                          label: 'Cadastre os dados da sua empresa',
                          foreground: theme.colorScheme.primaryForeground,
                        ),
                        _InfoItem(
                          icon: Symbols.admin_panel_settings,
                          label: 'Crie o usuário administrador',
                          foreground: theme.colorScheme.primaryForeground,
                        ),
                        _InfoItem(
                          icon: Symbols.rocket_launch,
                          label: 'Comece a usar o sistema',
                          foreground: theme.colorScheme.primaryForeground,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ------------------------------------------------------------------ Right wizard panel
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Stepper(
                controller: _steperController,
                steps: [
                  Step(
                    icon: StepNumber(
                      onPressed: () {
                        _steperController.jumpToStep(0);
                      },
                    ),
                    title: const Text('Empresa'),
                    contentBuilder: (context) {
                      return StepContainer(
                        actions: [PrimaryButton(onPressed: _onNext, child: const Text('Continuar'))],
                        child: SizedBox(
                          height: formHeight,
                          child: StepCompanyForm(key: _stepCompanyKey, model: CompanyModel.empty()),
                        ),
                      );
                    },
                  ),
                  Step(
                    icon: StepNumber(
                      onPressed: () {
                        _steperController.jumpToStep(1);
                      },
                    ),
                    title: const Text('Administrador'),
                    contentBuilder: (context) {
                      return Obx(() {
                        final isSaving = viewModel.isSaving.value;
                        return StepContainer(
                          actions: [
                            OutlineButton(
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      viewModel.previousStep();
                                      _steperController.previousStep();
                                    },
                              child: const Text('Voltar'),
                            ),
                            PrimaryButton(
                              onPressed: isSaving ? null : _onFinish,
                              child: Row(
                                spacing: 8,
                                children: [
                                  if (isSaving)
                                    const CircularProgressIndicator(size: 16)
                                  else
                                    const Icon(Symbols.check_circle, size: 18),
                                  Text(isSaving ? 'Salvando...' : 'Concluir'),
                                ],
                              ),
                            ),
                          ],
                          child: SizedBox(
                            height: formHeight,
                            child: StepAdminUserForm(key: _stepAdminKey, model: UserModel.empty()),
                          ),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;

  const _InfoItem({required this.icon, required this.label, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: foreground.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: foreground),
        ),
        Text(
          label,
          style: TextStyle(color: foreground, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
