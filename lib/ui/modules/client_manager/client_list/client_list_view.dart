// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/ui/modules/client_manager/client_list/client_list_view_model.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_actions.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_description.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_icon_text.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_title.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_updated_at.dart';
import 'package:versystems_app/data/models/client/client_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_widget.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_widget.dart';
import 'package:versystems_app/ui/modules/client_manager/client_list/components/client_details_sheet.dart';

class ClientListView extends StatefulWidget {
  const ClientListView({super.key});

  @override
  State<ClientListView> createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView> with MessageViewMixin, ResponsiveDeviceMixin {
  final viewModel = Get.find<ClientListViewModel>();

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
    viewModel.addListener(() {
      Future.microtask(() => setState(() {}));
    });
  }

  void _showDetails(BuildContext context, ClientModel client) {
    openSheet(
      context: context,
      builder: (_) {
        return ClientDetailsSheet(client: client, onExit: () => closeSheet(context));
      },
      position: OverlayPosition.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return FxAppListWidget<ClientModel>(
      screenSize: isSmallScreen
          ? ScreenSize.isSmallScreen
          : isMediumScreen
          ? ScreenSize.isMediumScreen
          : ScreenSize.isLargeScreen,
      pageStatus: viewModel.pageStatus,
      showStatusTab: true,
      statusList: [ClientStatusVisual(ClientStatusEnum.active), ClientStatusVisual(ClientStatusEnum.inactive)],
      listTitle: 'Lista de Clientes',
      listSubtitle: 'Gerencie seus clientes',
      newItemLabel: 'Novo Cliente',
      searchHint: 'Buscar cliente...',
      statusFilterFunction: (_) {},
      onViewChange: (_) {},
      searchTextFunction: (_) {},
      onRefresh: () => viewModel.findAllClients({}),
      onNewItem: () => context.go(RoutesHelper.clientManager),
      onItemClicked: (client) => _showDetails(context, client),
      items: viewModel.clients,
      columns: [
        AppTableColumnTitle(title: 'Nome', dataSelector: (item) => item.name),
        AppTableColumnStatus(title: 'Status'),
        AppTableColumnWidget(
          title: 'Tipo',
          dataSelector: (item) =>
              Text(item.clientType == ClientType.legal ? 'Pessoa Jurídica' : 'Pessoa Física').xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            mainAxisAlignment: .end,
            spacing: 5,
            children: [
              Icon(Symbols.person, size: 16, color: Colors.slate),
              SizedBox(width: 130, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.person, size: 16, color: Colors.slate),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 140, child: content),
        ),
        AppTableColumnWidget(
          title: 'E-mail',
          dataSelector: (item) => Text(item.email).xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            mainAxisAlignment: .end,
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
          dataSelector: (item) => Text(item.phone).xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            mainAxisAlignment: .end,
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
              onPressed: (context) => context.go('${RoutesHelper.clients}/${item.id}'),
              icon: Symbols.edit_square_rounded,
            ),
            AppTableColumnActionPress(label: 'Excluir', onPressed: (context) => viewModel.deleteClient(item.id), icon: Symbols.scan_delete_rounded),
          ],
        ),
      ],
    );
  }
}
