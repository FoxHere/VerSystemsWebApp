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

class _FormExecViewState extends State<TaskManagerView>
    with SingleTickerProviderStateMixin, MessageViewMixin, ResponsiveDeviceMixin {
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

  void _showActivityInstructionsModal(BuildContext context, ActivityModel taskModel) {
    final formulary = taskModel.formulary;
    final sectionsCount = formulary?.sections.length ?? 0;
    int questionsCount = 0;
    int requiredCount = 0;

    if (formulary?.sections != null) {
      for (final section in formulary!.sections) {
        questionsCount += section.questions.length;
        for (final question in section.questions) {
          if (question.questionRequired) {
            requiredCount++;
          }
        }
      }
    }

    final hasInstructions = taskModel.instructions != null && taskModel.instructions!.isNotEmpty;

    showOverlay(
      context,
      DialogConfiguration(
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Instruções da Atividade'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    // INFORMAÇÕES DO FORMULÁRIO
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Icon(Symbols.description, size: 20, color: Theme.of(context).colorScheme.primary),
                              Text('INFORMAÇÕES DO FORMULÁRIO').bold().small(),
                            ],
                          ),
                          if (formulary?.title != null && formulary!.title.isNotEmpty)
                            Text(formulary.title).medium(),
                          if (formulary?.description != null && formulary!.description.isNotEmpty)
                            Text(formulary.description).muted().small(),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlineBadge(child: Text('Seções: $sectionsCount')),
                              OutlineBadge(child: Text('Total de perguntas: $questionsCount')),
                              OutlineBadge(child: Text('Campos obrigatórios: $requiredCount')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    // INSTRUÇÕES DA ATIVIDADE
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Icon(Symbols.integration_instructions, size: 20, color: Theme.of(context).colorScheme.primary),
                              Text('INSTRUÇÕES DA ATIVIDADE').bold().small(),
                            ],
                          ),
                          Text(
                            hasInstructions ? taskModel.instructions! : 'Sem instruções específicas para esta atividade.',
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              PrimaryButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _generateReportDialog(BuildContext context, FxPdfStyles styles) async {
    if (!context.mounted) return;
    showOverlay(
      context,
      DialogConfiguration(
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Relatório do Formulário'),
                GhostButton(
                  density: ButtonDensity.compact,
                  onPressed: () => context.pop(),
                  child: const Icon(Symbols.close, size: 20),
                ),
              ],
            ),
            content: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.border),
              ),
              clipBehavior: Clip.hardEdge,
              child: ReportView(styles: styles, task: taskManagerViewModel.taskModel.value!),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: PrimaryButton(onPressed: () => context.pop(), child: const Text('Fechar')),
              ),
            ],
          );
        },
      ),
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
          child: Builder(
            builder: (context) {
              return Column(
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
                          leading: const Icon(Symbols.arrow_back, size: 18),
                          onPressed: () => context.go(RoutesHelper.tasks),
                          child: const Text('Voltar'),
                        ),
                        OutlineButton(
                          leading: const Icon(Symbols.summarize, size: 18),
                          onPressed: () => _generateReportDialog(context, pdfStyles),
                          child: const Text('Relatório'),
                        ),
                        if (status != ActivityStatusEnum.done)
                          Obx(() {
                            return PrimaryButton(
                              leading: const Icon(Symbols.save, size: 18),
                              onPressed:
                                  isImageConverting.value == true ||
                                      taskManagerViewModel.pageStatus.value is PageStatusLoading
                                  ? null
                                  : () async {
                                      final formState = formWidgetKey.currentState;

                                      final activityForm = formState?.formStructure;
                                      await taskManagerViewModel.saveTaskForm(activityForm!, ActivityStatusEnum.editing);
                                      if (taskManagerViewModel.pageStatus.value is PageStatusSuccess && context.mounted) {
                                        context.go(RoutesHelper.tasks);
                                      }
                                    },
                              child: const Text('Salvar Rascunho'),
                            );
                          }),
                        if (status != ActivityStatusEnum.done)
                          FormErrorBuilder(
                            builder: (context, errors, child) => PrimaryButton(
                              leading: const Icon(Icons.send, size: 18),
                              onPressed:
                                  (isImageConverting.value == true ||
                                          taskManagerViewModel.pageStatus.value is PageStatusLoading) ||
                                      errors.isNotEmpty
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 16,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(taskModel.name).h3(),
                                        const SizedBox(height: 12),
                                        OutlineButton(
                                          leading: Icon(Symbols.integration_instructions, size: 18, color: Theme.of(context).colorScheme.primary),
                                          onPressed: () => _showActivityInstructionsModal(context, taskModel),
                                          child: const Text('Instruções da Atividade'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
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
                                          if (taskManagerViewModel.pageStatus.value is PageStatusSuccess &&
                                              context.mounted) {
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
              );
            },
          ),
        ),
      ),
    );
  }
}
