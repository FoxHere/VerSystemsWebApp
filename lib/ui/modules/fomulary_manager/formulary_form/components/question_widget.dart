import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_type_model.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/form_manager_view_model.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({super.key, required this.viewModel, required this.sIndex});

  final FormManagerViewModel viewModel;
  final int sIndex;

  @override
  State<QuestionWidget> createState() => _QuestionWidget2State();
}

class _QuestionWidget2State extends State<QuestionWidget> {
  bool _requiresOptions(String dataType) {
    return dataType == 'listboxMultiSelect' ||
        dataType == 'listboxSingleSelect' ||
        dataType == 'radioButtonInput' ||
        dataType == 'checkboxInput';
  }

  void _showOptionsDialog(BuildContext context, QuestionModel q, String sectionId) {
    List<String> currentOptions = q.questionOptions
            ?.split(RegExp(r';\n|[\n;]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Opções da Pergunta'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Adicione as opções de escolha para esta pergunta:').muted(),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: currentOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: TextField(
                                  initialValue: currentOptions[index],
                                  onChanged: (val) {
                                    currentOptions[index] = val;
                                  },
                                  placeholder: const Text('Opção...'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Symbols.close),
                                variance: ButtonStyle.ghost(),
                                onPressed: () {
                                  setState(() {
                                    currentOptions.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlineButton(
                      onPressed: () {
                        setState(() {
                          currentOptions.add('Nova Opção');
                        });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Symbols.add), SizedBox(width: 8), Text('Adicionar Opção')],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlineButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                PrimaryButton(
                  onPressed: () {
                    final newString = currentOptions.map((e) => e.trim()).where((e) => e.isNotEmpty).join('\n');
                    widget.viewModel.updateQuestionUi(
                      sectionId: sectionId,
                      questionId: q.id,
                      update: (current) => current.copyWith(questionOptions: newString),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return SizedBox(
      child: SortableLayer(
        lock: true,
        child: SortableDropFallback<int>(
          onAccept: (value) {
            // Drop fora de um target específico -> joga pro final
            final section = widget.viewModel.questionnaire.value.sections[widget.sIndex];
            final uiList = widget.viewModel.uiQuestionsBySectionId[section.id];
            if (uiList == null) return;
            final len = uiList.length;
            widget.viewModel.moveQuestionUiByIndex(widget.sIndex, value.data, len);
          },
          child: ScrollableSortableLayer(
            controller: scrollController,
            child: Obx(() {
              final section = widget.viewModel.questionnaire.value.sections[widget.sIndex];
              final uiList = widget.viewModel.uiQuestionsBySectionId[section.id];
              if (uiList == null) {
                // isso pode acontecer antes do initialize terminar
                return const SizedBox.shrink();
              }
              const double rowHeight = 56;
              return ListView.builder(
                controller: scrollController,
                itemCount: uiList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  final sd = uiList[i]; // SortableData<QuestionModel>
                  final q = sd.data; // QuestionModel
                  return Sortable<QuestionModel>(
                    // chave estável: id do model
                    key: ValueKey(q.id),
                    // payload estável: o mesmo SortableData que está na lista (não recria)
                    data: sd,
                    // placeholder fixo pra não colapsar layout durante o drag
                    placeholder: const SizedBox(height: rowHeight),
                    onAcceptTop: (dragged) {
                      final fromIndex = uiList.indexOf(dragged);
                      if (fromIndex == -1) return;
                      widget.viewModel.moveQuestionUiByIndex(widget.sIndex, fromIndex, i);
                    },
                    onAcceptBottom: (dragged) {
                      final fromIndex = uiList.indexOf(dragged);
                      if (fromIndex == -1) return;
                      widget.viewModel.moveQuestionUiByIndex(widget.sIndex, fromIndex, i + 1);
                    },
                    child: SizedBox(
                      height: rowHeight,
                      child: OutlinedContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          spacing: 10,
                          children: [
                            const Icon(Icons.drag_indicator),
                            Text('Q${i + 1}'),
                            Expanded(
                              child: TextField(
                                initialValue: q.question,
                                placeholder: Text('Digite sua pergunta aqui...'),
                                onChanged: (value) {
                                  widget.viewModel.updateQuestionUi(
                                    sectionId: section.id,
                                    questionId: q.id,
                                    update: (current) => current.copyWith(question: value),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: Select<QuestionType>(
                                itemBuilder: (context, item) {
                                  return Text(item.typeTitle);
                                },
                                onChanged: (value) {
                                  widget.viewModel.updateQuestionUi(
                                    sectionId: section.id,
                                    questionId: q.id,
                                    update: (current) => current.copyWith(questionType: value?.dataType),
                                  );
                                },
                                value: widget.viewModel.questionTypeList.firstWhere((e) => e.dataType == q.questionType),
                                popup: SelectPopup(
                                  items: SelectItemList(
                                    children: [...widget.viewModel.questionTypeList.map((e) => SelectItemButton(value: e, child: Text(e.typeTitle)))],
                                  ),
                                ).call,
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Center(
                                child: Switch(
                                  value: q.questionRequired,
                                  onChanged: (value) {
                                    widget.viewModel.updateQuestionUi(
                                      sectionId: section.id,
                                      questionId: q.id,
                                      update: (current) => current.copyWith(questionRequired: value),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Row(
                                children: [
                                  if (_requiresOptions(q.questionType))
                                    IconButton(
                                      icon: const Icon(Symbols.list),
                                      variance: ButtonStyle.ghost(),
                                      onPressed: () => _showOptionsDialog(context, q, section.id),
                                    ),
                                  IconButton(
                                    icon: Icon(Symbols.add),
                                    variance: ButtonStyle.ghost(),
                                    onPressed: () {
                                      widget.viewModel.addQuestion(widget.sIndex);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Symbols.content_copy),
                                    variance: ButtonStyle.ghost(),
                                    onPressed: () {
                                      widget.viewModel.duplicateQuestion(widget.sIndex, i);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Symbols.variable_remove),
                                    variance: ButtonStyle.ghost(),
                                    onPressed: () {
                                      return widget.viewModel.removeQuestion(widget.sIndex, i);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).marginOnly(bottom: 10),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
    // return Row(
    //   children: [
    //     Expanded(child: Text('Pergunta ${qIndex + 1}')),
    //     IconButton(onPressed: () => viewModel.addQuestion(sIndex), icon: const Icon(Icons.add), variance: ButtonStyle.ghost()),
    //     IconButton(
    //       variance: ButtonStyle.ghost(),
    //       onPressed: () {
    //         viewModel.removeQuestionById(sIndex, questionId);
    //         if (viewModel.questionnaire.value.sections[sIndex].questions.isEmpty) {
    //           viewModel.addQuestion(sIndex);
    //         }
    //       },
    //       icon: const Icon(Icons.remove),
    //     ),
    //   ],
    // );
  }
}
