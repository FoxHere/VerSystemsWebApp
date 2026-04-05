// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_list/profile_list_view_model.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_actions.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_description.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_icon_text.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_title.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_updated_at.dart';
import 'package:versystems_app/data/models/profile/profile_status.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_widget.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_list/components/profile_details_sheet.dart';

class ProfileListView extends StatefulWidget {
  const ProfileListView({super.key});

  @override
  State<ProfileListView> createState() => _ProfileListViewState();
}

class _ProfileListViewState extends State<ProfileListView> with MessageViewMixin, ResponsiveDeviceMixin {
  final viewModel = Get.find<ProfileListViewModel>(tag: 'depList');
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

  void _showDetails(BuildContext context, ProfileModel profile) {
    openSheet(
      context: context,
      builder: (context) {
        return ProfileDetailsSheet(profile: profile, onExit: () => closeSheet(context));
      },
      position: OverlayPosition.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return FxAppListWidget<ProfileModel>(
      screenSize: isSmallScreen
          ? ScreenSize.isSmallScreen
          : isMediumScreen
          ? ScreenSize.isMediumScreen
          : ScreenSize.isLargeScreen,
      pageStatus: viewModel.pageStatus,
      showStatusTab: true,
      statusList: [ProfileStatusVisual(ProfileStatusEnum.active), ProfileStatusVisual(ProfileStatusEnum.inactive)],
      listTitle: 'Perfis',
      listSubtitle: 'Gerencie os perfis de usuário',
      newItemLabel: 'Novo Perfil',
      searchHint: 'Buscar perfil...',
      statusFilterFunction: (_) {},
      onViewChange: (_) {},
      searchTextFunction: (_) {},
      onRefresh: () => viewModel.findAllProfiles({}),
      onNewItem: () => context.go(RoutesHelper.profilesManager),
      onItemClicked: (profile) => _showDetails(context, profile),
      items: viewModel.profileList,
      columns: [
        AppTableColumnTitle(title: 'Nome', dataSelector: (item) => item.name),
        AppTableColumnStatus(title: 'Status'),
        AppTableColumnDescription(title: 'Descrição', dataSelector: (item) => item.description),
        AppTableColumnIconText(title: 'Nível', icon: Symbols.signal_cellular_alt, dataSelector: (item) => item.level.toString()),
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
              onPressed: (context) => context.go('${RoutesHelper.profiles}/${item.id}'),
              icon: Symbols.edit_square_rounded,
            ),
            AppTableColumnActionPress(label: 'Excluir', onPressed: (context) => viewModel.deleteProfile(item.id), icon: Symbols.scan_delete_rounded),
          ],
        ),
      ],
    );
  }
}
