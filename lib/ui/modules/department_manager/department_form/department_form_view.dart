import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/app_page_status_builder.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/ui/modules/department_manager/department_form/department_form_view_model.dart';
import 'package:versystems_app/ui/modules/department_manager/department_form/components/department_form.dart';

class DepartmentFormView extends StatefulWidget {
  final String departmentId;

  const DepartmentFormView({super.key, required this.departmentId});

  @override
  State<DepartmentFormView> createState() => _DepartmentFormViewState();
}

class _DepartmentFormViewState extends State<DepartmentFormView>
    with
        SingleTickerProviderStateMixin,
        MessageViewMixin,
        ResponsiveDeviceMixin {
  final DepartmentFormViewModel viewModel = Get.find<DepartmentFormViewModel>();

  late AnimationController _animationController;
  late Animation<double> _animation;
  final formWidgetKey = GlobalKey<DepartmentFormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.initialize(widget.departmentId);
    });

    messageListener(viewModel);
    viewModel.addListener(() {
      Future.microtask(() {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    final theme = Theme.of(context);

    return Scaffold(
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.border),
                ),
                color: theme.colorScheme.background,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.departmentId == 'new'
                              ? 'Novo Departamento'
                              : 'Editar Departamento',
                        ).h3(),
                        const Text(
                          'Crie e estruture os departamentos da organização.',
                        ).muted().small(),
                      ],
                    ),
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      SecondaryButton(
                        onPressed: () => context.go(RoutesHelper.departments),
                        child: const Row(
                          spacing: 8,
                          children: [
                            Icon(Symbols.arrow_back, size: 18),
                            Text('Voltar'),
                          ],
                        ),
                      ),
                      PrimaryButton(
                        onPressed: () async {
                          final formState = formWidgetKey.currentState;
                          if (formState != null && formState.validateForm()) {
                            final departmentFormModel =
                                formState.departmentModel;
                            await viewModel.saveDepartment(departmentFormModel);
                            if (viewModel.pageStatus.value
                                    is PageStatusSuccess &&
                                context.mounted) {
                              context.go(RoutesHelper.departments);
                            }
                          }
                        },
                        child: Obx(() {
                          final isLoading =
                              viewModel.pageStatus.value is PageStatusLoading;
                          return Row(
                            spacing: 8,
                            children: [
                              if (isLoading)
                                const CircularProgressIndicator(size: 16)
                              else
                                const Icon(Symbols.save, size: 18),
                              Text(isLoading ? 'Salvando...' : 'Salvar'),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Content Area
            Expanded(
              child: Obx(() {
                return AppPageStatusBuilder<DepartmentModel>(
                  pageStatus: viewModel.pageStatus.value,
                  successBuilder: (model) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: DepartmentForm(
                            key: formWidgetKey,
                            model: model,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
