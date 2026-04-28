import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/components/report/report_view.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/components/task_form.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/task_manager_view_model.dart';
import 'package:versystems_app/config/utils/app_page_status_builder.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_styles.dart';

class TaskManagerView extends StatefulWidget {
  final String taskId;

  const TaskManagerView({super.key, required this.taskId});

  @override
  State<TaskManagerView> createState() => _FormExecViewState();
}

class _FormExecViewState extends State<TaskManagerView> with SingleTickerProviderStateMixin, MessageViewMixin, ResponsiveDeviceMixin {
  final taskManagerViewModel = Get.find<TaskManagerViewModel>();
  final imageServices = Get.find<ImageServices>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final formWidgetKey = GlobalKey<TaskFormState>();
  final isImageConverting = RxBool(false);
  final FormController _formController = FormController();
  late final FxPdfStyles pdfStyles;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();

    messageListener(taskManagerViewModel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      taskManagerViewModel.initialize(widget.taskId);
    });
    initialize();
  }

  Future<void> initialize() async {
    pdfStyles = await FxPdfStyles.init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateReportDialog(BuildContext context, FxPdfStyles styles) async {
    if (!context.mounted) return;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gerar Relatório do Formulário'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: ReportView(styles: styles, task: taskManagerViewModel.taskModel.value!),
          ),
          actions: [PrimaryButton(onPressed: () => context.pop(), child: const Text('Fechar'))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();

    final status = taskManagerViewModel.taskModel.value?.activityStatus;
    return Scaffold(
      child: FadeTransition(
        opacity: _animation,
        child: Form(
          controller: _formController,
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
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Minha Tarefa').h3(),
                          const SizedBox(height: 4),
                          const Text('Preencha as informações do formulário para executar sua tarefa').muted(),
                        ],
                      ),
                    ),
                    OutlineButton(
                      leading: Icon(Symbols.arrow_back, size: 18),
                      onPressed: () => context.go(RoutesHelper.tasks),
                      child: const Text('Voltar'),
                    ),
                    OutlineButton(
                      leading: Icon(Symbols.summarize, size: 18),
                      onPressed: () => _generateReportDialog(context, pdfStyles),
                      child: Text('Relatório'),
                    ),
                    if (status != ActivityStatusEnum.done)
                      Obx(() {
                        return PrimaryButton(
                          leading: Icon(Symbols.save, size: 18),
                          onPressed: isImageConverting.value == true || taskManagerViewModel.pageStatus.value is PageStatusLoading
                              ? null
                              : () async {
                                  final formState = formWidgetKey.currentState;

                                  final activityForm = formState?.formStructure;
                                  await taskManagerViewModel.saveTaskForm(activityForm!, ActivityStatusEnum.editing);
                                  if (taskManagerViewModel.pageStatus.value is PageStatusSuccess && context.mounted) {
                                    context.go(RoutesHelper.tasks);
                                  }
                                },
                          child: Text('Salvar Rascunho'),
                        );
                      }),
                    if (status != ActivityStatusEnum.done)
                      FormErrorBuilder(
                        builder: (context, errors, child) => PrimaryButton(
                          leading: Icon(Icons.send, size: 18),
                          onPressed:
                              (isImageConverting.value == true || taskManagerViewModel.pageStatus.value is PageStatusLoading) || errors.isNotEmpty
                              ? null
                              : () async {
                                  final formState = formWidgetKey.currentState;
                                  if (formState != null && formState.validateForm()) {
                                    final activityForm = formState.formStructure;
                                    await taskManagerViewModel.saveTaskForm(activityForm, ActivityStatusEnum.done);
                                    if (taskManagerViewModel.pageStatus.value is PageStatusSuccess && context.mounted) {
                                      context.go(RoutesHelper.tasks);
                                    }
                                  }
                                },
                          child: const Text('Enviar Respostas'),
                        ),
                      ),
                  ],
                ),
              ),
              // Form Content Area
              Expanded(
                child: Obx(() {
                  return AppPageStatusBuilder<ActivityModel>(
                    pageStatus: taskManagerViewModel.pageStatus.value,
                    successBuilder: (taskModel) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 16,
                              children: [
                                Text(taskModel.name).h3(),
                                if (taskModel.instructions != null && taskModel.instructions!.isNotEmpty) Text(taskModel.instructions!).muted(),
                                const SizedBox(height: 16),
                                TaskForm(
                                  isImageConverting: isImageConverting,
                                  controller: _formController,
                                  imageServices: imageServices,
                                  formKey: formKey,
                                  key: formWidgetKey,
                                  formStructure: taskModel.formulary!,
                                  isReadMode: taskModel.activityStatus == ActivityStatusEnum.done,
                                  onSubmit: (formStructure) async {
                                    if (isImageConverting.value == true) return;
                                    final formState = formWidgetKey.currentState;
                                    if (formState != null && formState.validateForm()) {
                                      await taskManagerViewModel.saveTaskForm(formStructure, ActivityStatusEnum.done);
                                      if (taskManagerViewModel.pageStatus.value is PageStatusSuccess && context.mounted) {
                                        context.go(RoutesHelper.tasks);
                                      }
                                    }
                                  },
                                  onImageRemoved: (image) {
                                    taskManagerViewModel.removedImagesList.add(image);
                                  },
                                ),
                              ],
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
      ),
    );
  }
}
