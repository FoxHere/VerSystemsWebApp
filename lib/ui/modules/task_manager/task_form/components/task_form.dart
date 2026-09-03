import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_type_model.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';
import 'package:versystems_app/ui/shared/components/widget_builder/widget_type_builder.dart';

class TaskForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final FormularyModel formStructure;
  final bool isReadMode;
  final Function(FormularyModel) onSubmit;
  final Function(ImageItemModel) onImageRemoved;
  final ImageServices imageServices;
  final RxBool isImageConverting;
  final ValueChanged<FormularyModel>? onChanged;
  final FormController? controller;

  const TaskForm({
    super.key,
    required this.formKey,
    required this.formStructure,
    required this.onSubmit,
    required this.onImageRemoved,
    this.isReadMode = false,
    required this.imageServices,
    required this.isImageConverting,
    this.onChanged,
    this.controller,
  });

  @override
  State<TaskForm> createState() => TaskFormState();
}

class TaskFormState extends State<TaskForm> {
  FormularyModel get formStructure => widget.formStructure.copyWith();
  late final FormController _formController = widget.controller ?? FormController();
  final Map<int, bool> _collapsedSections = {};

  bool validateForm() {
    _formController.revalidate(context, FormValidationMode.submitted);
    // Force UI update to show errors
    setState(() {});
    return _formController.errors.isEmpty;
  }

  void _showQuestionInstructionsModal(BuildContext context, String questionTitle, String instructions) {
    showOverlay(
      context,
      DialogConfiguration(
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Instruções da Pergunta'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text(questionTitle).bold().small(),
                  const Divider(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 350),
                    child: SingleChildScrollView(
                      child: Text(
                        instructions,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                ],
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

  final questionTypeList = <QuestionType>[
    TypeSimpleText(),
    TypeNumber(),
    TypeTelephone(),
    TypeCellphone(),
    TypeCnpj(),
    TypeCpf(),
    TypeRg(),
    TypeHiddenText(),
    TypeListBoxSingleSelect(),
    TypeListBoxMultiSelect(),
    TypeRadioButton(),
    TypeCheckbox(),
    TypeImagePicker(),
    TypeDateInput(),
    TypeTimeInput(),
    TypeSignature(),
    TypeGpsLocation(),
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      controller: _formController,
      child: Builder(
        builder: (formContext) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 24,
            children: [
              // ------------------------------------------------------------------- SECTIONS
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.formStructure.sections.length,
                separatorBuilder: (context, index) => const SizedBox(height: 24),
                itemBuilder: (context, sIndex) {
                  final section = widget.formStructure.sections[sIndex];
                  final isCollapsed = _collapsedSections[sIndex] ?? false;

                  return Card(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        // Section title header with collapse toggle button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _collapsedSections[sIndex] = !isCollapsed;
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(section.sectionTitle).large()),
                              GhostButton(
                                density: ButtonDensity.compact,
                                onPressed: () {
                                  setState(() {
                                    _collapsedSections[sIndex] = !isCollapsed;
                                  });
                                },
                                child: Icon(
                                  isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (!isCollapsed) ...[
                          const Divider(),

                          // --------------------------------------------------------- QUESTIONS
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: section.questions.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, qIndex) {
                              final question = section.questions[qIndex];
                              final hasInstructions = question.questionInstructions != null && question.questionInstructions!.isNotEmpty;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.muted.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Theme.of(context).colorScheme.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ------------------------------------------------ QUESTION HEAD
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '${qIndex + 1}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: RichText(
                                                  softWrap: true,
                                                  text: TextSpan(
                                                    text: question.question,
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.foreground,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                      height: 1.5,
                                                    ),
                                                    children: [
                                                      if (question.questionRequired)
                                                        TextSpan(
                                                          text: ' *',
                                                          style: TextStyle(
                                                            color: Theme.of(context).colorScheme.destructive,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (hasInstructions) ...[
                                          const SizedBox(width: 12),
                                          OutlineButton(
                                            onPressed: () => _showQuestionInstructionsModal(
                                              context,
                                              question.question,
                                              question.questionInstructions!,
                                            ),
                                            leading: const Icon(Icons.description, size: 16),
                                            child: const Text('Instruções'),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // // ------------------------------------------------ QUESTION TYPE
                                    WidgetTypeBuilder(
                                      fieldKey: question.id,
                                      isReadMode: widget.isReadMode,
                                      isImageConverting: widget.isImageConverting,
                                      hasValidator: question.questionRequired,
                                      imageServices: widget.imageServices,
                                      initialValue: question.response?.toString(),
                                      initialSignature: question.signatureResponse,
                                      initialImages: question.imagesResponse,
                                      initialLocation: question.locationResponse,
                                      questionType: questionTypeList.firstWhere(
                                        (element) => element.dataType == question.questionType,
                                        orElse: () => TypeSimpleText(),
                                      ),
                                      items: question.questionOptions
                                              ?.split(RegExp(r';\n|[\n;]'))
                                              .map((item) => item.trim())
                                              .where((item) => item.isNotEmpty)
                                              .toList() ??
                                          [],
                                      onSelectChanged: (value) {
                                        question.response = value;
                                      },
                                      onSelectionChanged: (value) {
                                        question.response = value.join(';');
                                      },
                                      onChanged: (value) {
                                        question.response = value;
                                      },
                                      onLocationCaptured: (location) {
                                        question.locationResponse = location;
                                        question.response = location.toJson();
                                      },
                                      onImagePicker: (images) async {
                                        final existingImages = question.imagesResponse
                                            ?.where((img) => img.downloadUrl != null && img.downloadUrl!.isNotEmpty)
                                            .toList();
                                        final newImages = images.where((img) => img.downloadUrl == null || img.downloadUrl!.isEmpty).toList();
                                        question.imagesResponse = [...existingImages ?? [], ...newImages];
                                      },
                                      onSignatureSelected: (image) {
                                        if (image.bytes.isEmpty && (image.downloadUrl == null || image.downloadUrl!.isEmpty)) {
                                          question.signatureResponse = null;
                                        } else {
                                          question.signatureResponse = image;
                                        }
                                      },
                                      onImageRemoved: (image) {
                                        question.imagesResponse = (question.imagesResponse as List<ImageItemModel>)
                                            .where((img) => img.downloadUrl != image.downloadUrl)
                                            .toList();
                                        if (question.imagesResponse!.isEmpty) question.imagesResponse = null;
                                        widget.onImageRemoved(image);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
