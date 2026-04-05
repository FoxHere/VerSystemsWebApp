// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/ui/modules/user_manager/user_list/user_list_view_model.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_actions.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_icon_text.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_title.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_updated_at.dart';
import 'package:versystems_app/data/models/user/user_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_widget.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_widget.dart';
import 'package:versystems_app/ui/modules/user_manager/user_list/components/user_details_sheet.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> with MessageViewMixin, ResponsiveDeviceMixin {
  final viewModel = Get.find<UserListViewModel>(tag: 'depList');
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

  void _showDetails(BuildContext context, UserModel user) {
    openSheet(
      context: context,
      builder: (_) {
        return UserDetailsSheet(user: user, onExit: () => closeSheet(context));
      },
      position: OverlayPosition.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return FxAppListWidget<UserModel>(
      screenSize: isSmallScreen
          ? ScreenSize.isSmallScreen
          : isMediumScreen
          ? ScreenSize.isMediumScreen
          : ScreenSize.isLargeScreen,
      pageStatus: viewModel.pageStatus,
      showStatusTab: true,
      statusList: [UserStatusVisual(UserStatusEnum.active), UserStatusVisual(UserStatusEnum.inactive)],
      listTitle: 'Gerenciamento de Usuários',
      listSubtitle: 'Gerencie os usuários e suas atribuições',
      newItemLabel: 'Novo usuário',
      searchHint: 'Buscar usuário...',
      statusFilterFunction: (_) {},
      onViewChange: (_) {},
      searchTextFunction: (_) {},
      onRefresh: () => viewModel.findAllUsers({}),
      onNewItem: () => context.go(RoutesHelper.usersManager),
      onItemClicked: (user) => _showDetails(context, user),
      items: viewModel.userList,
      columns: [
        AppTableColumnTitle(title: 'Nome', dataSelector: (item) => item.name),
        AppTableColumnStatus(title: 'Status'),
        AppTableColumnWidget(
          title: 'Departamento',
          dataSelector: (item) => Text(item.department.name).xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            mainAxisAlignment: .end,
            spacing: 5,
            children: [
              Icon(Symbols.corporate_fare, size: 16, color: Colors.slate),
              SizedBox(width: 90, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.business_center, size: 16, color: Colors.slate),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 140, child: content),
        ),
        AppTableColumnWidget(
          title: 'Empresa',
          dataSelector: (item) => Text(item.company).xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            mainAxisAlignment: .end,
            spacing: 5,
            children: [
              Icon(Symbols.corporate_fare, size: 16, color: Colors.slate),
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
          cardPosition: (content) => Positioned(left: 15, bottom: 120, child: content),
        ),
        AppTableColumnWidget(
          title: 'Perfil',
          dataSelector: (item) => Text(item.profile.name).xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            mainAxisAlignment: .end,
            spacing: 5,
            children: [
              Icon(Symbols.corporate_fare, size: 16, color: Colors.slate),
              SizedBox(width: 90, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.badge, size: 16, color: Colors.slate),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 100, child: content),
        ),
        AppTableColumnWidget(
          title: 'E-mail',
          dataSelector: (item) => Text(item.email).xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            mainAxisAlignment: .end,
            spacing: 5,
            children: [
              Icon(Symbols.mail, size: 16, color: Colors.slate),
              SizedBox(width: 100, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.mail, size: 16, color: Colors.slate),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 35, child: content),
        ),
        AppTableColumnWidget(
          title: 'Celular',
          dataSelector: (item) => Text(item.cellphones.isNotEmpty ? item.cellphones.first : 'N/A').xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            mainAxisAlignment: .end,
            spacing: 5,
            children: [
              Icon(Symbols.cell_tower, size: 16, color: Colors.slate),
              SizedBox(width: 130, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.cell_tower, size: 16, color: Colors.slate),
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
              onPressed: (context) => context.go('${RoutesHelper.users}/${item.id}'),
              icon: Symbols.edit_square_rounded,
            ),
            AppTableColumnActionPress(label: 'Excluir', onPressed: (context) => viewModel.deleteUser(item.id), icon: Symbols.scan_delete_rounded),
          ],
        ),
      ],
    );
  }
}
