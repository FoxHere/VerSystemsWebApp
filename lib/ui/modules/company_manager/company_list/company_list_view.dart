// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/models/company/company_status.dart';
import 'package:versystems_app/ui/modules/company_manager/company_list/company_list_view_model.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_actions.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_description.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_icon_text.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_title.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_updated_at.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_widget.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_widget.dart';
import 'package:versystems_app/ui/modules/company_manager/company_list/components/company_details_sheet.dart';

class CompanyListView extends StatefulWidget {
  const CompanyListView({super.key});

  @override
  State<CompanyListView> createState() => _CompanyListViewState();
}

class _CompanyListViewState extends State<CompanyListView> with MessageViewMixin, ResponsiveDeviceMixin {
  final viewModel = Get.find<CompanyListViewModel>();

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
    viewModel.addListener(() {
      Future.microtask(() => setState(() {}));
    });
  }

  void _showDetails(BuildContext context, CompanyModel company) {
    openSheet(
      constraints: const BoxConstraints(maxWidth: 1000),
      context: context,
      builder: (_) {
        return CompanyDetailsSheet(company: company, onExit: () => closeSheet(context));
      },
      position: OverlayPosition.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return FxAppListWidget<CompanyModel>(
      screenSize: isSmallScreen
          ? ScreenSize.isSmallScreen
          : isMediumScreen
          ? ScreenSize.isMediumScreen
          : ScreenSize.isLargeScreen,
      pageStatus: viewModel.pageStatus,
      showStatusTab: true,
      statusList: CompanyStatusEnum.values.map((e) => CompanyStatusVisual(e)).toList(),
      listTitle: 'Minhas Empresas',
      listSubtitle: 'Gerencie as suas empresas',
      newItemLabel: 'Nova Empresa',
      searchHint: 'Buscar empresa...',
      statusFilterFunction: (_) {},
      onViewChange: (_) {},
      searchTextFunction: (_) {},
      onRefresh: () => viewModel.findAllCompanies({}),
      onNewItem: () => context.go(RoutesHelper.companyManager),
      onItemClicked: (company) => _showDetails(context, company),
      items: viewModel.companies,
      columns: [
        AppTableColumnTitle(title: 'Nome', dataSelector: (item) => item.name),
        AppTableColumnDescription(title: 'Nome Fantasia', dataSelector: (item) => item.tradeName ?? 'Nome fantasia não informado'),
        AppTableColumnStatus(title: 'Status'),
        AppTableColumnWidget(
          title: 'CNPJ',
          dataSelector: (item) => Text(item.cnpj).xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.business_center, size: 16, color: Colors.slate),
              SizedBox(width: 130, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.business_center, size: 16, color: Colors.slate),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 70, child: content),
        ),
        AppTableColumnWidget(
          title: 'E-mail',
          dataSelector: (item) => Text(item.email ?? '').xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.email, size: 16, color: Colors.slate),
              SizedBox(width: 130, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.email, size: 16, color: Colors.slate),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 35, child: content),
        ),
        AppTableColumnWidget(
          title: 'Telefone',
          dataSelector: (item) => Text(item.phone ?? '').xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.phone, size: 16, color: Colors.slate),
              SizedBox(width: 130, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.phone, size: 16, color: Colors.slate),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 15, child: content),
        ),
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
              onPressed: (context) => context.go('${RoutesHelper.companies}/${item.id}'),
              icon: Symbols.edit_square_rounded,
            ),
            AppTableColumnActionPress(label: 'Excluir', onPressed: (context) => viewModel.deleteCompany(item.id), icon: Symbols.scan_delete_rounded),
          ],
        ),
      ],
    );
  }
}
