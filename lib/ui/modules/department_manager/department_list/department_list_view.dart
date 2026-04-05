// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/ui/modules/department_manager/department_list/department_list_view_model.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_actions.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_description.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_title.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_updated_at.dart';
import 'package:versystems_app/data/models/department/department_status.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_widget.dart';
import 'package:versystems_app/ui/modules/department_manager/department_list/components/department_details_sheet.dart';

class DepartmentListView extends StatefulWidget {
  const DepartmentListView({super.key});

  @override
  State<DepartmentListView> createState() => _DepartmentListViewState();
}

class _DepartmentListViewState extends State<DepartmentListView> with MessageViewMixin, ResponsiveDeviceMixin {
  final viewModel = Get.find<DepartmentListViewModel>(tag: 'depList');
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
    viewModel.addListener(() {
      Future.microtask(() => setState(() {}));
    });
  }

  @override
  void dispose() {
    viewModel.removeListener(() {});
    super.dispose();
  }

  void _showDetails(BuildContext context, DepartmentModel department) {
    openSheet(
      context: context,
      builder: (context) {
        return DepartmentDetailsSheet(department: department, onExit: () => closeSheet(context));
      },
      position: OverlayPosition.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return FxAppListWidget<DepartmentModel>(
      screenSize: isSmallScreen
          ? ScreenSize.isSmallScreen
          : isMediumScreen
          ? ScreenSize.isMediumScreen
          : ScreenSize.isLargeScreen,
      pageStatus: viewModel.pageStatus,
      showStatusTab: true,
      statusList: [DepartmentStatusVisual(DepartmentStatusEnum.active), DepartmentStatusVisual(DepartmentStatusEnum.inactive)],
      listTitle: 'Gerenciamento de Departamentos',
      listSubtitle: 'Gerencie os departamentos da empresa',
      newItemLabel: 'Novo Departamento',
      searchHint: 'Buscar departamento...',
      statusFilterFunction: (_) {},
      onViewChange: (_) {},
      searchTextFunction: (_) {},
      onRefresh: () => viewModel.findAllDepartments({}),
      onNewItem: () => context.go(RoutesHelper.departmentsManager),
      onItemClicked: (department) => _showDetails(context, department),
      items: viewModel.departmentList,
      columns: [
        AppTableColumnTitle(title: 'Nome', dataSelector: (item) => item.name),
        AppTableColumnStatus(title: 'Status'),
        AppTableColumnDescription(title: 'Descrição', dataSelector: (item) => item.description),
        AppTableColumnUpdatedAt(
          title: 'Última atualização',
          needToShowOnCard: false,
          dataSelector: (item) => item.updatedAt?.toIso8601String() ?? '',
        ),
        AppTableColumnActions(
          title: 'Ações',
          dataSelector: (item) => [
            AppTableColumnActionPress(
              label: 'Editar',
              onPressed: (context) => context.go('${RoutesHelper.departments}/${item.id}'),
              icon: Symbols.edit_square_rounded,
            ),
            AppTableColumnActionPress(
              label: 'Excluir',
              onPressed: (context) => viewModel.deleteDepartment(item.id),
              icon: Symbols.scan_delete_rounded,
            ),
          ],
        ),
      ],
    );
  }
}
