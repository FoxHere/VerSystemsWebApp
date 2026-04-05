import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/boudaries.dart';
import 'package:versystems_app/config/controllers/app_state/app_state_controller.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/app_page_status_builder.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/components/import_excel_dialog.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/components/section_widget.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/form_manager_view_model.dart';

class FormManagerView extends StatefulWidget {
  final String formId;

  const FormManagerView({super.key, required this.formId});

  @override
  State<FormManagerView> createState() => _FormManagerViewState();
}

class _FormManagerViewState extends State<FormManagerView> with ResponsiveDeviceMixin, MessageViewMixin {
  final viewModel = Get.find<FormManagerViewModel>();
  final AppStateController appStateController = Get.find<AppStateController>();

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.initialize(widget.formId);
    });
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          spacing: Boudaries.spacing,
          children: [
            Row(
              // ----------------------------------- Header ----------------------
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text('Gerenciar Formulário').h3(),
                    Text('Monte seu formulário customizado organizando campos e seções').light(color: Colors.slate),
                  ],
                ),
                Expanded(
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Symbols.arrow_back),
                        variance: ButtonStyle.outline(),
                        onPressed: () {
                          context.go(RoutesHelper.formularies);
                        },
                      ),
                      // ---------------------- New Item Button ----------------------
                      OutlineButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) {
                            return ImportExcelDialog(
                              formularyId: widget.formId,
                              onImport: (formulary) {
                                viewModel.setNewFormulary(formulary);
                              },
                            );
                          },
                        ),
                        child: Row(spacing: 10, children: [Icon(Symbols.upload), Text('Import Formulário')]),
                      ),
                      PrimaryButton(
                        leading: Icon(Symbols.save),
                        onPressed: () async {
                          appStateController.formHasUnsavedValues.value = false;
                          await viewModel.onSaveFormulary();
                          if (!appStateController.formHasUnsavedValues.value) {
                            if (viewModel.pageStatus.value is PageStatusSuccess && context.mounted) {
                              context.go(RoutesHelper.formularies);
                            }
                          }
                        },
                        child: Text('Salvar Formulário'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ----------------------------------- Content ----------------------
            Row(
              crossAxisAlignment: .start,
              children: [
                // ----------------------------------- Left Content ----------------------
                SizedBox(
                  width: constraints.maxWidth - 550,
                  height: constraints.maxHeight - 110,
                  child: Obx(() {
                    return AppPageStatusBuilder<Rx<FormularyModel>>(
                      pageStatus: viewModel.pageStatus.value,
                      successBuilder: (model) {
                        return Column(
                          /// essa coluna é somente para manter os items alinhados no topo
                          children: [
                            Expanded(
                              child: CustomScrollView(
                                shrinkWrap: true,
                                slivers: [
                                  // ----------------------------------- Basic Information ----------------------
                                  SliverToBoxAdapter(
                                    child: OutlinedContainer(
                                      width: double.infinity,
                                      child: Collapsible(
                                        isExpanded: true,
                                        children: [
                                          CollapsibleTrigger(child: Text('Informações básicas').h4()),
                                          CollapsibleContent(
                                            child: Column(
                                              spacing: 10,
                                              children: [
                                                Obx(() {
                                                  return TextField(
                                                    placeholder: Text('Título do formulário'),
                                                    initialValue: viewModel.questionnaire.value.title,
                                                    onChanged: (value) {
                                                      viewModel.questionnaire.value.title = value;
                                                    },
                                                  );
                                                }),
                                                Obx(() {
                                                  return TextField(
                                                    placeholder: Text('Descrição do formulário'),
                                                    initialValue: viewModel.questionnaire.value.description,
                                                    onChanged: (value) {
                                                      viewModel.questionnaire.value.description = value;
                                                    },
                                                  );
                                                }),
                                              ],
                                            ).paddingAll(15),
                                          ),
                                        ],
                                      ).paddingSymmetric(vertical: 15),
                                    ).marginOnly(right: 10),
                                  ),
                                  // ----------------------------------- Sections ----------------------
                                  SliverToBoxAdapter(
                                    child: Obx(() {
                                      return ListView.builder(
                                        itemCount: viewModel.questionnaire.value.sections.length,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, i) {
                                          return SectionWidget(viewModel: viewModel, sIndex: i).marginOnly(right: 10, top: 10);
                                        },
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),

                // ----------------------------------- Sections ----------------------

                // ----------------------------------- Right Content ----------------------
                SizedBox(
                  width: 500,
                  height: 200,
                  child: Column(
                    children: [
                      Obx(() {
                        final totalSections = viewModel.questionnaire.value.sections.length;
                        final summary = viewModel.questionnaire.value.sections.fold(0, (sum, section) => sum + section.questions.length);
                        final requiredFields = viewModel.questionnaire.value.sections.fold(
                          0,
                          (sum, section) => sum + section.questions.where((question) => question.questionRequired).length,
                        );
                        final optionalFields = viewModel.questionnaire.value.sections.fold(
                          0,
                          (sum, section) => sum + section.questions.where((question) => !question.questionRequired).length,
                        );
                        return Card(
                          child: SizedBox(
                            width: double.infinity,
                            height: 135,
                            child: Column(
                              spacing: 3,
                              crossAxisAlignment: .start,
                              children: [
                                Text('Resumo').h4,
                                Spacer(),
                                Row(mainAxisAlignment: .spaceBetween, children: [Text('Seções:').small(), Text(totalSections.toString()).small()]),
                                Row(mainAxisAlignment: .spaceBetween, children: [Text('Total de campos:').small(), Text(summary.toString()).small()]),
                                Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [Text('Campos obrigatórios:').small(), Text(requiredFields.toString()).small()],
                                ),
                                Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [Text('Campos opcionais:').small(), Text(optionalFields.toString()).small()],
                                ),
                              ],
                            ),
                          ),
                        ).paddingOnly(left: Boudaries.spacing);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ).paddingAll(Boudaries.spacing);
      },
    );
  }
}
