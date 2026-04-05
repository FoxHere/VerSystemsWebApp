import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/app_page_status_builder.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_form/activity_manager_view_model.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_form/components/activity_form.dart';

class ActivityManagerView extends StatefulWidget {
  final String activityId;

  const ActivityManagerView({super.key, required this.activityId});

  @override
  State<ActivityManagerView> createState() => _ActivityManagerViewState();
}

class _ActivityManagerViewState extends State<ActivityManagerView> with SingleTickerProviderStateMixin, MessageViewMixin, ResponsiveDeviceMixin {
  final viewModel = Get.find<ActivityManagerViewModel>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final formWidgetKey = GlobalKey<ActivityFormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.initialize(widget.activityId);
    });

    messageListener(viewModel);
    // viewModel.addListener(() {
    //   Future.microtask(() {
    //     if (mounted) setState(() {});
    //   });
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();

    return Scaffold(
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.activityId == 'new' ? 'Nova Atividade' : 'Editar Atividade').h3(),
                        const SizedBox(height: 4),
                        Text('Preencha as informações abaixo para gerenciar a atividade').muted(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlineButton(
                        onPressed: () => context.go(RoutesHelper.activities),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Symbols.arrow_back, size: 18), SizedBox(width: 8), Text('Voltar')],
                        ),
                      ),
                      const SizedBox(width: 12),
                      PrimaryButton(
                        onPressed: viewModel.pageStatus.value is PageStatusLoading
                            ? null
                            : () async {
                                final formState = formWidgetKey.currentState;
                                if (formState != null && formState.validateForm()) {
                                  final activityForm = formState.activityModel;
                                  await viewModel.onSaveActivity(activityForm);
                                  if (viewModel.pageStatus.value is PageStatusSuccess && context.mounted) {
                                    context.go(RoutesHelper.activities);
                                  }
                                }
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (viewModel.pageStatus.value is PageStatusLoading)
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            else ...[
                              const Icon(Symbols.save, size: 18),
                              const SizedBox(width: 8),
                            ],
                            const Text('Salvar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Content Area
            Expanded(
              child: Obx(() {
                return AppPageStatusBuilder<ActivityModel>(
                  pageStatus: viewModel.pageStatus.value,
                  successBuilder: (activityModel) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: ActivityForm(
                            key: formWidgetKey,
                            model: activityModel,
                            availableFormularyList: viewModel.availableFormularyList,
                            availableUsersList: viewModel.availableUsersList,
                            availableClientsList: viewModel.availableClientsList,
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
