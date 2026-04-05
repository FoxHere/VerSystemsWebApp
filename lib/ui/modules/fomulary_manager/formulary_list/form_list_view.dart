import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/app_strings_helper.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/models/formulary/formulary_status_enum.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_list/form_list_view_model.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_actions.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_created_by.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_description.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_icon_text.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_title.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_updated_at.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_widget.dart';

class FormListView extends StatefulWidget {
  const FormListView({super.key});

  @override
  State<FormListView> createState() => _FormListViewState();
}

class _FormListViewState extends State<FormListView> with MessageViewMixin, ResponsiveDeviceMixin, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  // late Animation<double> _animation;

  final viewModel = Get.find<FormListViewModel>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    // _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    messageListener(viewModel);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final isCardsView = true.obs;

  void _onViewChange(bool value) {
    isCardsView.value = value;
    // print('isCardsView: $isCardsView');
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return FxAppListWidget<FormularyModel>(
      screenSize: isSmallScreen
          ? ScreenSize.isSmallScreen
          : isMediumScreen
          ? ScreenSize.isMediumScreen
          : ScreenSize.isLargeScreen,
      pageStatus: viewModel.pageStatus,
      showStatusTab: true,
      listTitle: AppStringsHelper.formListHeader,
      listSubtitle: AppStringsHelper.formListSubtitle,
      newItemLabel: 'Novo formulário',
      searchHint: 'Buscar formulário...',
      statusList: FormStatusEnum.values.map((e) => FormStatusVisual(e)).toList(),
      statusFilterFunction: (value) {
        if (value.isEmpty) {
          viewModel.filterMap.remove('status');
        } else {
          viewModel.filterMap['status'] = value;
        }
        viewModel.filterFormulary(viewModel.filterMap);
        // print('filterMap: ${viewModel.filterMap}');
      },
      searchTextFunction: (value) {
        // print('searchText: ');
        if (value.isEmpty) {
          viewModel.filterMap.remove('search');
        } else {
          viewModel.filterMap['search'] = value;
        }
        viewModel.filterFormulary(viewModel.filterMap);
      },
      onRefresh: () {
        viewModel.findAllFormulary({});
      },
      onNewItem: () {
        context.go(RoutesHelper.formulariesManager);
      },
      // isCardsView: isCardsView.value,
      onViewChange: (value) {
        _onViewChange(value);
      },
      onSortColumn: (sortOption) {
        viewModel.sortByColumn(sortOption);
      },
      items: viewModel.filteredFormularyList,
      columns: [
        AppTableColumnTitle(title: 'Name', dataSelector: (item) => item.title.toString()),
        AppTableColumnDescription(title: 'Description', dataSelector: (item) => item.description.toString()),
        AppTableColumnStatus(title: 'Status'),
        AppTableColumnIconText(
          title: 'Questões',
          icon: Symbols.mode_comment,
          dataSelector: (item) => item.questionsCount.toString(),
          // cardPosition: (content) => Positioned(right: 25, bottom: 15, child: content),
        ),
        AppTableColumnCreatedBy(title: 'Criado por', dataSelector: (item) => item.createdBy, updatedAtSelector: (item) => item.updatedAt.toString()),
        AppTableColumnUpdatedAt(title: 'Ultima Atualização', needToShowOnCard: false, dataSelector: (item) => item.updatedAt.toString()),
        AppTableColumnActions(
          title: 'Actions',
          dataSelector: (item) => [
            AppTableColumnActionPress(
              label: 'Edit',
              onPressed: (context) {
                // print('Edit');
                context.go('${RoutesHelper.formularies}/${item.id}');
              },
              icon: Symbols.edit_square_rounded,
            ),
            AppTableColumnActionPress(
              label: 'Delete',
              onPressed: (context) {
                // print('Delete');
                viewModel.deleteFormulary(item.id);
              },
              icon: Symbols.scan_delete_rounded,
            ),
            AppTableColumnSwitchAction(
              label: 'Ativo',
              onPressed: (context) {},
              icon: Symbols.scan_delete_rounded,
              value: item.formStatus == FormStatusEnum.active,
              onChanged: (value) {
                viewModel.changeFormularyStatus(item);
              },
            ),
          ],
        ),
      ],
    );
  }
}
