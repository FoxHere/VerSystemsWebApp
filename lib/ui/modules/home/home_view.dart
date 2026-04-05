import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/ui/modules/home/home_view_model.dart';
import 'package:versystems_app/ui/shared/appbar/appbar_widget.dart';
import 'package:versystems_app/ui/shared/sidebar/sidebar_widget.dart';

class HomeView extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final GoRouterState state;

  const HomeView({super.key, required this.navigationShell, required this.state});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with MessageViewMixin, ResponsiveDeviceMixin, SingleTickerProviderStateMixin {
  final viewModel = Get.find<HomeViewModel>();
  final authController = Get.find<AuthController>();
  final expanded = true.obs;

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
  }

  SidebarWidget buildSidebar() {
    return SidebarWidget(
      expanded: expanded,
      homeViewModel: viewModel,
      state: widget.state,
      onExpanded: (value) {
        expanded.value = value;
      },
    );
  }

  void open(BuildContext context) {
    // Definimos sempre como true ao abrir para forçar a abertura em tamanho real no Sheet
    expanded.value = true;
    openSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: 250, // Fixa a largura do sheet para não ter engasgo ao renderizar
          child: SidebarWidget(
            expanded: expanded,
            homeViewModel: viewModel,
            state: widget.state,
            onExpanded: (value) {
              expanded.value = value;
            },
          ),
        );
      },
      position: OverlayPosition.left,
    );
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return Scaffold(
      headers: [
        AppbarWidget(
          expanded: expanded,
          onExpanded: (value) {
            expanded.value = value;
          },
          openDrawer: () => open(context),
        ),
        const Divider(),
      ],
      footers: [],
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          if (isLargeScreen)
            SidebarWidget(
              expanded: expanded,
              homeViewModel: viewModel,
              state: widget.state,
              onExpanded: (value) {
                expanded.value = value;
              },
            ),
          VerticalDivider(),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }
}
