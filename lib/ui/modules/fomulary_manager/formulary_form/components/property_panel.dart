import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_type_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/section_model.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/form_manager_view_model.dart';

class PropertyPanel extends StatefulWidget {
  final FormManagerViewModel viewModel;

  const PropertyPanel({super.key, required this.viewModel});

  @override
  State<PropertyPanel> createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  final Map<String, TextEditingController> _retrievedControllers = {};
  String? _lastSectionId;
  String? _lastQuestionId;

  bool _requiresOptions(String dataType) {
    return dataType == 'listboxMultiSelect' ||
        dataType == 'listboxSingleSelect' ||
        dataType == 'radioButtonInput' ||
        dataType == 'checkboxInput';
  }

  TextEditingController _getSectionTitleController(String id, String initialValue) {
    return _retrievedControllers.putIfAbsent('${id}_title', () {
      return widget.viewModel.getSectionController(id, initialValue);
    });
  }

  TextEditingController _getQuestionController(String id, String initialValue) {
    return _retrievedControllers.putIfAbsent('${id}_text', () {
      return widget.viewModel.getQuestionController(id, initialValue);
    });
  }

  void _releaseAllControllers() {
    _retrievedControllers.forEach((key, controller) {
      if (key.endsWith('_title')) {
        final id = key.substring(0, key.length - 6);
        widget.viewModel.releaseSectionController(id, controller);
      } else if (key.endsWith('_text')) {
        final id = key.substring(0, key.length - 5);
        widget.viewModel.releaseQuestionController(id, controller);
      }
    });
    _retrievedControllers.clear();
  }

  void _checkSelectionAndRelease(String? sectionId, String? questionId) {
    if (sectionId != _lastSectionId || questionId != _lastQuestionId) {
      _releaseAllControllers();
      _lastSectionId = sectionId;
      _lastQuestionId = questionId;
    }
  }

  @override
  void dispose() {
    _releaseAllControllers();
    super.dispose();
  }

  void _showInstructionsDialog(BuildContext context, SectionModel section, QuestionModel question) {
    final textController = TextEditingController(text: question.questionInstructions ?? '');

    showOverlay(
      context,
      DialogConfiguration(
        builder: (context) {
          return AlertDialog(
            title: const Text('Instruções da Pergunta'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  const Text('Insira orientações detalhadas de preenchimento para esta pergunta:').muted().small(),
                  TextArea(
                    controller: textController,
                    placeholder: const Text('Escreva as instruções aqui...'),
                    minLines: 4,
                    maxLines: 8,
                  ),
                ],
              ),
            ),
            actions: [
              OutlineButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
              PrimaryButton(
                onPressed: () {
                  final val = textController.text;
                  widget.viewModel.updateQuestionUi(
                    sectionId: section.id,
                    questionId: question.id,
                    update: (current) => current.copyWith(questionInstructions: val),
                  );
                  widget.viewModel.appStateController.formHasUnsavedValues.value = true;
                  Navigator.of(context).pop();
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedSectionId = widget.viewModel.selectedSectionId.value;
      final selectedQuestionId = widget.viewModel.selectedQuestionId.value;

      _checkSelectionAndRelease(selectedSectionId, selectedQuestionId);

      if (selectedSectionId != null && selectedQuestionId == null) {
        return _buildSectionProperties(context, selectedSectionId);
      } else if (selectedSectionId != null && selectedQuestionId != null) {
        return _buildQuestionProperties(context, selectedSectionId, selectedQuestionId);
      } else {
        return _buildSummaryProperties(context);
      }
    });
  }

  Widget _buildSummaryProperties(BuildContext context) {
    final totalSections = widget.viewModel.questionnaire.value.sections.length;
    final totalQuestions = widget.viewModel.questionnaire.value.sections.fold(
      0,
      (sum, section) => sum + section.questions.length,
    );
    final requiredFields = widget.viewModel.questionnaire.value.sections.fold(
      0,
      (sum, section) => sum + section.questions.where((question) => question.questionRequired).length,
    );
    final optionalFields = widget.viewModel.questionnaire.value.sections.fold(
      0,
      (sum, section) => sum + section.questions.where((question) => !question.questionRequired).length,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Resumo do Formulário').h4(), const Icon(Symbols.analytics, size: 20)],
            ),
            const Divider(),
            _buildSummaryRow('Seções', totalSections.toString()),
            _buildSummaryRow('Total de perguntas', totalQuestions.toString()),
            _buildSummaryRow('Campos obrigatórios', requiredFields.toString()),
            _buildSummaryRow('Campos opcionais', optionalFields.toString()),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: OutlineButton(
                leading: const Icon(Symbols.add_box),
                onPressed: () {
                  widget.viewModel.addSection();
                },
                child: const Text('Adicionar Nova Seção'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label).small(), Text(value).small().bold()],
    );
  }

  Widget _buildSectionProperties(BuildContext context, String sectionId) {
    final section = widget.viewModel.questionnaire.value.sections.firstWhereOrNull((s) => s.id == sectionId);
    if (section == null) {
      return Card(
        child: Padding(padding: const EdgeInsets.all(24), child: Text('Seção não encontrada.').muted()),
      );
    }

    final sIndex = widget.viewModel.questionnaire.value.sections.indexOf(section);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Propriedades da Seção').h4(),
                const OutlineBadge(child: Text('Seção')),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: FormField<String>(
                    key: FormKey<String>(ValueKey('prop_section_title_${section.id}')),
                    label: const Text('Título da Seção'),
                    child: TextField(
                      controller: _getSectionTitleController(section.id, section.sectionTitle),
                      placeholder: const Text('Título da seção'),
                      onChanged: (val) {
                        section.sectionTitle = val;
                        widget.viewModel.questionnaire.refresh();
                        widget.viewModel.appStateController.formHasUnsavedValues.value = true;
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Total de perguntas:').small(), Text('${section.questions.length}').small().bold()],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                OutlineButton(
                  leading: const Icon(Symbols.add),
                  onPressed: () {
                    widget.viewModel.addQuestion(sIndex);
                  },
                  child: const Text('Adicionar Pergunta'),
                ),
                OutlineButton(
                  leading: const Icon(Symbols.add_box),
                  onPressed: () {
                    widget.viewModel.addSection(sIndex);
                  },
                  child: const Text('Adicionar Nova Seção'),
                ),
                OutlineButton(
                  leading: const Icon(Symbols.content_copy),
                  onPressed: () {
                    widget.viewModel.duplicateSection(sIndex);
                  },
                  child: const Text('Duplicar Seção'),
                ),
                DestructiveButton(
                  leading: const Icon(Symbols.delete),
                  onPressed: () {
                    widget.viewModel.removeSection(sIndex);
                  },
                  child: const Text('Remover Seção'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionProperties(BuildContext context, String sectionId, String questionId) {
    final section = widget.viewModel.questionnaire.value.sections.firstWhereOrNull((s) => s.id == sectionId);
    final question = section?.questions.firstWhereOrNull((q) => q.id == questionId);

    if (section == null || question == null) {
      return Card(
        child: Padding(padding: const EdgeInsets.all(24), child: Text('Pergunta não encontrada.').muted()),
      );
    }

    final sIndex = widget.viewModel.questionnaire.value.sections.indexOf(section);
    final qIndex = section.questions.indexOf(question);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Propriedades').h4(),
                      Text('Seção: ${section.sectionTitle}').xSmall().muted(),
                    ],
                  ),
                ),
                const OutlineBadge(child: Text('Pergunta')),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: FormField<String>(
                    key: FormKey<String>(ValueKey('prop_question_text_${question.id}')),
                    label: const Text('Texto da Pergunta'),
                    child: TextField(
                      controller: _getQuestionController(question.id, question.question),
                      placeholder: const Text('Texto da pergunta'),
                      onChanged: (val) {
                        widget.viewModel.updateQuestionUi(
                          sectionId: section.id,
                          questionId: question.id,
                          update: (current) => current.copyWith(question: val),
                        );
                        widget.viewModel.appStateController.formHasUnsavedValues.value = true;
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FormField<QuestionType>(
                    key: FormKey<QuestionType>(ValueKey('prop_question_type_${question.id}')),
                    label: const Text('Tipo da Pergunta'),
                    child: SizedBox(
                      width: double.infinity,
                      child: Select<QuestionType>(
                        value: widget.viewModel.questionTypeList.firstWhere((e) => e.dataType == question.questionType, orElse: () => TypeSimpleText()),
                        itemBuilder: (context, item) {
                          return Text(item.typeTitle);
                        },
                        onChanged: (value) {
                          if (value != null) {
                            widget.viewModel.updateQuestionUi(
                              sectionId: section.id,
                              questionId: question.id,
                              update: (current) => current.copyWith(questionType: value.dataType),
                            );
                            widget.viewModel.appStateController.formHasUnsavedValues.value = true;
                          }
                        },
                        popup: SelectPopup(
                          items: SelectItemList(
                            children: [
                              ...widget.viewModel.questionTypeList.map(
                                (e) => SelectItemButton(value: e, child: Text(e.typeTitle)),
                              ),
                            ],
                          ),
                        ).call,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Campo obrigatório').small(),
                Switch(
                  value: question.questionRequired,
                  onChanged: (value) {
                    widget.viewModel.updateQuestionUi(
                      sectionId: section.id,
                      questionId: question.id,
                      update: (current) => current.copyWith(questionRequired: value),
                    );
                    widget.viewModel.appStateController.formHasUnsavedValues.value = true;
                  },
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                FormField<String>(
                  key: FormKey<String>(ValueKey('prop_question_inst_${question.id}')),
                  label: const Text('Instruções da Pergunta'),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlineButton(
                      leading: const Icon(Symbols.notes),
                      onPressed: () {
                        _showInstructionsDialog(context, section, question);
                      },
                      child: Text(
                        (question.questionInstructions ?? '').trim().isEmpty
                            ? 'Adicionar Instrução'
                            : 'Editar Instrução',
                      ),
                    ),
                  ),
                ),
                if ((question.questionInstructions ?? '').trim().isNotEmpty)
                  Text(
                    question.questionInstructions!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).small().muted().marginOnly(top: 2),
              ],
            ),
            if (_requiresOptions(question.questionType)) ...[
              const Divider(),
              _buildOptionsEditor(context, section, question),
            ],
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                OutlineButton(
                  leading: const Icon(Symbols.add),
                  onPressed: () {
                    widget.viewModel.addQuestion(sIndex);
                  },
                  child: const Text('Adicionar Pergunta'),
                ),
                OutlineButton(
                  leading: const Icon(Symbols.content_copy),
                  onPressed: () {
                    widget.viewModel.duplicateQuestion(sIndex, qIndex);
                  },
                  child: const Text('Duplicar Pergunta'),
                ),
                DestructiveButton(
                  leading: const Icon(Symbols.delete),
                  onPressed: () {
                    widget.viewModel.removeQuestion(sIndex, qIndex);
                  },
                  child: const Text('Remover Pergunta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsEditor(BuildContext context, SectionModel section, QuestionModel question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Opções de Escolha').small().bold(),
            OutlineButton(
              size: ButtonSize.small,
              onPressed: () {
                widget.viewModel.addOptionToSelectedQuestion();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [Icon(Symbols.add, size: 16), Text('Adicionar')],
              ),
            ),
          ],
        ),
        Obx(() {
          final controllers = widget.viewModel.selectedQuestionOptionControllers;
          if (controllers.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Nenhuma opção cadastrada.').muted(),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controllers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final controller = controllers[index];
              return Row(
                key: ValueKey(controller),
                spacing: 8,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (val) {
                        widget.viewModel.updateQuestionOptionsFromControllers(section.id, question.id);
                      },
                      placeholder: const Text('Opção'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Symbols.close, size: 18),
                    variance: ButtonStyle.ghost(),
                    onPressed: () {
                      widget.viewModel.removeOptionFromSelectedQuestion(index);
                    },
                  ),
                ],
              );
            },
          );
        }),
      ],
    );
  }
}
