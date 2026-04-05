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

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
  }

  void _onNext() {
    if (viewModel.currentStep.value == 0) {
      final isValid = _stepCompanyKey.currentState?.validateForm() ?? false;
      if (isValid) viewModel.nextStep();
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

    return Scaffold(
      child: Row(
        children: [
          // Left branding panel
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
                    Text('Bem-vindo à\nVerSystems Platform', textAlign: TextAlign.center, style: TextStyle(fontSize: 32)).h1,
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
                        _InfoItem(icon: Symbols.business, label: 'Cadastre os dados da sua empresa', foreground: theme.colorScheme.primaryForeground),
                        _InfoItem(
                          icon: Symbols.admin_panel_settings,
                          label: 'Crie o usuário administrador',
                          foreground: theme.colorScheme.primaryForeground,
                        ),
                        _InfoItem(icon: Symbols.rocket_launch, label: 'Comece a usar o sistema', foreground: theme.colorScheme.primaryForeground),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Right wizard panel
          Expanded(
            flex: 7,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
                    color: theme.colorScheme.background,
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      if (isMediumScreen || isSmallScreen) ...[Assets.images.common.logos.logo01.image(height: 36), const SizedBox(height: 16)],
                      Obx(() => SetupStepper(currentStep: viewModel.currentStep.value, steps: const ['Empresa', 'Administrador'])),
                    ],
                  ),
                ),

                // Form content
                Expanded(
                  child: Obx(() {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: viewModel.currentStep.value == 0
                          ? StepCompanyForm(key: _stepCompanyKey, model: CompanyModel.empty())
                          : StepAdminUserForm(key: _stepAdminKey, model: UserModel.empty()),
                    );
                  }),
                ),

                // Footer actions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.colorScheme.border)),
                    color: theme.colorScheme.background,
                  ),
                  child: Obx(() {
                    final isLastStep = viewModel.currentStep.value == 1;
                    final isSaving = viewModel.isSaving.value;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        if (viewModel.currentStep.value > 0)
                          SecondaryButton(
                            onPressed: isSaving ? null : () => viewModel.previousStep(),
                            child: const Row(spacing: 8, children: [Icon(Symbols.arrow_back, size: 18), Text('Voltar')]),
                          )
                        else
                          const SizedBox.shrink(),

                        // Next / Finish button
                        PrimaryButton(
                          onPressed: isSaving
                              ? null
                              : isLastStep
                              ? _onFinish
                              : _onNext,
                          child: Row(
                            spacing: 8,
                            children: [
                              if (isSaving)
                                const CircularProgressIndicator(size: 16)
                              else
                                Icon(isLastStep ? Symbols.check_circle : Symbols.arrow_forward, size: 18),
                              Text(
                                isSaving
                                    ? 'Salvando...'
                                    : isLastStep
                                    ? 'Concluir'
                                    : 'Próximo',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
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
