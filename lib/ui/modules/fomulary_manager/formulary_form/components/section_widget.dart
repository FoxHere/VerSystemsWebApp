import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:material_symbols_icons/symbols.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.slate.shade100, borderRadius: BorderRadius.circular(10)),
      child: Collapsible(
        isExpanded: true,
        children: [
          CollapsibleTrigger(
            child: Row(
              spacing: 10,
              children: [
                Text('S${widget.sIndex + 1}'),
                Expanded(
                  child: TextField(
                    placeholder: Text('Titulo da sessão'),
                    initialValue: widget.viewModel.questionnaire.value.sections[widget.sIndex].sectionTitle,
                    onChanged: (value) {
                      widget.viewModel.questionnaire.value.sections[widget.sIndex].sectionTitle = value;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Symbols.add_box),
                  variance: ButtonStyle.ghost(),
                  onPressed: () {
                    widget.viewModel.addSection();
                  },
                ),
                IconButton(
                  icon: Icon(Symbols.remove_from_queue),
                  variance: ButtonStyle.ghost(),
                  onPressed: () {
                    widget.viewModel.removeSection(widget.sIndex);
                  },
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Pergunta').xSmall.marginOnly(left: 40)),
                      SizedBox(width: 160, child: Text('Tipo Pergunta').xSmall),
                      SizedBox(width: 140, child: Text('Obrigatório').xSmall),
                      SizedBox(width: 110, child: Text('Ações').xSmall),
                    ],
                  ),
                  QuestionWidget(viewModel: widget.viewModel, sIndex: widget.sIndex),
                ],
              ).paddingAll(15),
            ),
          ),
        ],
      ).paddingSymmetric(vertical: 15),
    ).paddingOnly(bottom: 10);
  }
}
