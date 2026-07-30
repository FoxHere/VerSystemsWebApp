import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/section_model.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/form_manager_view_model.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({super.key, required this.viewModel, required this.sIndex});

  final FormManagerViewModel viewModel;
  final int sIndex;

  @override
  State<QuestionWidget> createState() => _QuestionWidget2State();
}

class _QuestionWidget2State extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return SizedBox(
      child: SortableLayer(
        lock: true,
        child: SortableDropFallback<int>(
          onAccept: (value) {
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
                  return QuestionRowWidget(
                    key: ValueKey(sd.data.id),
                    viewModel: widget.viewModel,
                    section: section,
                    sd: sd,
                    index: i,
                    sIndex: widget.sIndex,
                    rowHeight: rowHeight,
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class QuestionRowWidget extends StatefulWidget {
  final FormManagerViewModel viewModel;
  final SectionModel section;
  final SortableData<QuestionModel> sd;
  final int index;
  final int sIndex;
  final double rowHeight;

  const QuestionRowWidget({
    super.key,
    required this.viewModel,
    required this.section,
    required this.sd,
    required this.index,
    required this.sIndex,
    required this.rowHeight,
  });

  @override
  State<QuestionRowWidget> createState() => _QuestionRowWidgetState();
}

class _QuestionRowWidgetState extends State<QuestionRowWidget> {
  late TextEditingController _questionController;
  late String _questionId;

  @override
  void initState() {
    super.initState();
    _questionId = widget.sd.data.id;
    _questionController = widget.viewModel.getQuestionController(_questionId, widget.sd.data.question);
  }

  @override
  void dispose() {
    widget.viewModel.releaseQuestionController(_questionId, _questionController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.sd.data;
    return Obx(() {
      final isSelected = widget.viewModel.selectedSectionId.value == widget.section.id &&
          widget.viewModel.selectedQuestionId.value == q.id;

      return Sortable<QuestionModel>(
        key: ValueKey(q.id),
        data: widget.sd,
        placeholder: SizedBox(height: widget.rowHeight),
        onAcceptTop: (dragged) {
          final section = widget.viewModel.questionnaire.value.sections[widget.sIndex];
          final uiList = widget.viewModel.uiQuestionsBySectionId[section.id];
          if (uiList == null) return;
          final fromIndex = uiList.indexOf(dragged);
          if (fromIndex == -1) return;
          widget.viewModel.moveQuestionUiByIndex(widget.sIndex, fromIndex, widget.index);
        },
        onAcceptBottom: (dragged) {
          final section = widget.viewModel.questionnaire.value.sections[widget.sIndex];
          final uiList = widget.viewModel.uiQuestionsBySectionId[section.id];
          if (uiList == null) return;
          final fromIndex = uiList.indexOf(dragged);
          if (fromIndex == -1) return;
          widget.viewModel.moveQuestionUiByIndex(widget.sIndex, fromIndex, widget.index + 1);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.viewModel.selectQuestion(widget.section.id, q.id);
          },
          child: SizedBox(
            height: widget.rowHeight,
            child: OutlinedContainer(
              borderColor: isSelected ? Theme.of(context).colorScheme.primary : null,
              borderWidth: isSelected ? 2.0 : null,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                spacing: 10,
                children: [
                  const Icon(Icons.drag_indicator),

                  Expanded(
                    child: FormTableLayout(
                      rows: [
                        FormField<String>(
                          key: FormKey<String>(ValueKey('question_${q.id}')),
                          validator: const NotEmptyValidator(message: 'A pergunta é obrigatória'),
                          label: Text('Q${widget.index + 1}'),
                          child: TextField(
                            controller: _questionController,
                            placeholder: const Text('Digite sua pergunta aqui...'),
                            onTap: () {
                              widget.viewModel.selectQuestion(widget.section.id, q.id);
                            },
                            onChanged: (value) {
                              widget.viewModel.updateQuestionUi(
                                sectionId: widget.section.id,
                                questionId: q.id,
                                update: (current) => current.copyWith(question: value),
                              );
                              widget.viewModel.appStateController.formHasUnsavedValues.value = true;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
