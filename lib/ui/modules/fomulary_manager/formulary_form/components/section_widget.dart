import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/components/question_widget.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/form_manager_view_model.dart';

class SectionWidget extends StatefulWidget {
  const SectionWidget({super.key, required this.viewModel, required this.sIndex});

  final FormManagerViewModel viewModel;
  final int sIndex;

  @override
  State<SectionWidget> createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  final ScrollController scrollController = ScrollController();
  late TextEditingController _titleController;
  late String _sectionId;

  @override
  void initState() {
    super.initState();
    final section = widget.viewModel.questionnaire.value.sections[widget.sIndex];
    _sectionId = section.id;
    _titleController = widget.viewModel.getSectionController(_sectionId, section.sectionTitle);
  }

  @override
  void dispose() {
    widget.viewModel.releaseSectionController(_sectionId, _titleController);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final section = widget.viewModel.questionnaire.value.sections[widget.sIndex];
      final isSelected = widget.viewModel.selectedSectionId.value == section.id &&
          widget.viewModel.selectedQuestionId.value == null;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.viewModel.selectSection(section.id);
        },
        child: OutlinedContainer(
          borderColor: isSelected ? Theme.of(context).colorScheme.primary : null,
          borderWidth: isSelected ? 2.0 : null,
          backgroundColor: Colors.slate.shade100,
          child: Collapsible(
            isExpanded: true,
            children: [
              CollapsibleTrigger(
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: FormTableLayout(
                        rows: [
                          FormField<String>(
                            key: FormKey<String>(
                              ValueKey('section_${section.id}'),
                            ),
                            validator: const NotEmptyValidator(message: 'O título da sessão é obrigatório'),
                            label: Text('S${widget.sIndex + 1}'),
                            child: TextField(
                              placeholder: const Text('Titulo da sessão'),
                              controller: _titleController,
                              onTap: () {
                                widget.viewModel.selectSection(section.id);
                              },
                              onChanged: (value) {
                                section.sectionTitle = value;
                                widget.viewModel.questionnaire.refresh();
                                widget.viewModel.appStateController.formHasUnsavedValues.value = true;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).paddingOnly(bottom: 15, top: 15),
              ),
              CollapsibleContent(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    spacing: 10,
                    children: [
                      Text('Perguntas da Seção').xSmall.muted().marginOnly(left: 40),
                      QuestionWidget(viewModel: widget.viewModel, sIndex: widget.sIndex),
                    ],
                  ).paddingAll(15),
                ),
              ),
            ],
          ).paddingSymmetric(vertical: 15),
        ),
      ).paddingOnly(bottom: 10);
    });
  }
}
