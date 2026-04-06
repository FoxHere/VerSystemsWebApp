import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/data/models/sidebar/sidebar_item_model.dart';
import 'package:versystems_app/ui/modules/home/home_view_model.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key, required this.expanded, required this.onExpanded, required this.homeViewModel, required this.state});
  final RxBool expanded;
  final HomeViewModel homeViewModel;
  final GoRouterState state;

  final Function(bool value) onExpanded;

  @override
  State<SidebarWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SidebarWidget> {
  final selectedIndex = ''.obs;
  final List<SidebarEntry> allMenuItems = [
    SidebarDivider(),
    SidebarSection(label: 'Gestão'),
    MenuItemModel(icon: Symbols.dashboard, name: 'Dashboard', route: RoutesHelper.dashboard),
    MenuItemModel(icon: Symbols.format_list_bulleted, name: 'Formulários', route: RoutesHelper.formularies),
    MenuItemModel(icon: Symbols.editor_choice, name: 'Atividades', route: RoutesHelper.activities),
    MenuItemModel(icon: Symbols.fact_check, name: 'Minhas Tarefas', route: RoutesHelper.tasks),
    SidebarDivider(),
    SidebarSection(label: 'Cadastros'),
    MenuItemModel(icon: Symbols.business_center, name: 'Empresas', route: RoutesHelper.companies),
    MenuItemModel(icon: Symbols.support_agent, name: 'Clientes', route: RoutesHelper.clients),
    MenuItemModel(icon: Symbols.group, name: 'Usuários', route: RoutesHelper.users),
    MenuItemModel(icon: Symbols.badge, name: 'Perfis', route: RoutesHelper.profiles),
    MenuItemModel(icon: Symbols.category_search, name: 'Departamentos', route: RoutesHelper.departments),
    SidebarDivider(),
    SidebarSection(label: 'Sistema'),
    MenuItemModel(icon: Symbols.settings, name: 'Configurações', route: RoutesHelper.settings),
  ];

  NavigationItem buildNavItem(MenuItemModel item) {
    return NavigationItem(
      key: Key(item.route),
      enabled: true,
      alignment: Alignment.centerLeft,
      label: Text(item.name),
      selectedStyle: const ButtonStyle.primaryIcon(),
      selected: widget.state.uri.path.contains(item.route),
      child: Icon(item.icon),
      onChanged: (selected) {
        if (selected) {
          selectedIndex.value = item.route;
          widget.state.uri.toString();
          context.go(item.route);
        }
      },
    );
  }

  NavigationGroup buildLabel(String label, List<Widget> children) {
    // Section header used to group related navigation items.
    return NavigationGroup(labelAlignment: Alignment.centerLeft, label: Text(label).semiBold.muted.xSmall, children: children);
  }

  List<SidebarEntry> _filterSidebarItems(List<SidebarEntry> allMenuItems, List<String> allowedMenus) {
    final allowed = allowedMenus.toSet();
    final List<SidebarEntry> out = [];

    SidebarSection? currentSection;
    final List<MenuItemModel> currentItems = [];

    void flush() {
      if (currentSection == null) return;
      if (currentItems.isEmpty) {
        currentSection = null;
        currentItems.clear();
        return;
      }

      // dividir sempre antes de uma seção válida
      out.add(const SidebarDivider());
      out.add(currentSection!);
      out.addAll(currentItems);

      currentSection = null;
      currentItems.clear();
    }

    for (final entry in allMenuItems) {
      if (entry is SidebarSection) {
        flush();
        currentSection = entry;
      } else if (entry is MenuItemModel) {
        if (allowed.contains(entry.route)) {
          currentItems.add(entry);
        }
      }
      // SidebarDivider vindo do input é ignorado de propósito
      // (pois o filtro injeta automaticamente os dividers)
    }

    flush();
    return out;
  }

  int findSelectedIndex(List<MenuItemModel> items, String currentLocation) {
    // This function is used to find the index of the selected item in the list of items and the current location
    for (int i = 0; i < items.length; i++) {
      final route = items[i].route;
      if (route == currentLocation || currentLocation.startsWith(route)) {
        return i;
      }
    }
    return 0;
  }

  List<MenuItemModel> getSelectableItems(List<SidebarEntry> items) {
    // This function is used to get the list of selectable items from the list of items
    return items.whereType<MenuItemModel>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // This varible is here in the Obx because if the user is changed we can rebuild de menu items
      final loggedUser = widget.homeViewModel.authController.localUserModel.value;
      // Filtra com divider antes de cada seção
      final userAllowedMenuItems = List<String>.from(loggedUser?.profile.allowedMenus ?? const <String>[])
        ..add(RoutesHelper.settings)
        ..add(RoutesHelper.loggedProfile);
      
      final menuItems = _filterSidebarItems(allMenuItems, userAllowedMenuItems);

      // Construção dos filhos da NavigationRail agrupados corretamente railChildren
      List<Widget> railChildren = [];
      String? currentLabel;
      List<Widget> currentItems = [];

      // Função para adicionar items dentro do railChildren e limpar os currents;
      void flushSection() {
        // Add items no railChildren dependendo do tipo do item
        if (currentLabel != null && currentItems.isNotEmpty) {
          railChildren.add(buildLabel(currentLabel!, currentItems));
        } else if (currentItems.isNotEmpty) {
          railChildren.addAll(currentItems);
        }
        // Limpando os currents;
        currentLabel = null;
        currentItems = [];
      }

      for (final entry in menuItems) {
        if (entry is SidebarDivider) {
          flushSection();
          // Evita adicionar divider no topo se não houver filhos ainda
          railChildren.add(NavigationDivider(color: Colors.slate[200]));
          // if (railChildren.isNotEmpty) {}
        } else if (entry is SidebarSection) {
          flushSection();
          currentLabel = entry.label;
        } else if (entry is MenuItemModel) {
          currentItems.add(buildNavItem(entry));
        }
      }
      flushSection();

      return NavigationRail(
        backgroundColor: Theme.of(context).colorScheme.accent.withValues(alpha: 0.4),
        labelType: NavigationLabelType.expanded,
        labelPosition: NavigationLabelPosition.end,
        alignment: NavigationRailAlignment.start,
        expanded: widget.expanded.value,
        expandedSize: 250,
        header: [
          Builder(
            builder: (context) {
              return NavigationSlot(
                leading: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.violet, width: 2), // Diminuído border width de 5 para 2 para melhor renderização
                  ),
                  child: Avatar(
                    provider: loggedUser?.profileImage?.downloadUrl != null ? NetworkImage(loggedUser!.profileImage!.downloadUrl!) : null,
                    size: 32,
                    initials: Avatar.getInitials(loggedUser?.name ?? 'US'),
                    backgroundColor: Colors.violet,
                  ).paddingAll(2),
                  // child: Obx(() {
                  //   final profileImage = loggedUser?.profileImage;

                  // }),
                ),
                title: Text(loggedUser?.name ?? 'Usuário').medium.small,
                subtitle: Text(loggedUser?.email ?? '').xSmall.normal,
                trailing: const Icon(LucideIcons.chevronsUpDown).iconSmall,

                onPressed: () {
                  showDropdown(
                    context: context,
                    anchorAlignment: AlignmentDirectional.centerEnd,
                    alignment: AlignmentDirectional.centerStart,
                    offset: const Offset(16, 0),
                    builder: (context) {
                      return DropdownMenu(
                        children: [
                          MenuButton(
                            leading: const Icon(Icons.person),
                            child: const Text('Profile'),
                            onPressed: (ctx) {
                              ctx.go(RoutesHelper.loggedProfile);
                            },
                          ),
                          MenuButton(
                            leading: Icon(LucideIcons.panelRight),
                            child: Text(widget.expanded.value ? 'Colapsar Menu' : 'Expandir Menu'),
                            onPressed: (ctx) {
                              widget.onExpanded(!widget.expanded.value);
                            },
                          ),
                          if (loggedUser?.isAppAdmin == true)
                            MenuButton(
                              leading: const Icon(LucideIcons.building2),
                              child: const Text('Alternar Empresa'),
                              onPressed: (ctx) {
                                ctx.go(RoutesHelper.switchCompany);
                              },
                            ),
                          const MenuDivider(),
                          MenuButton(
                            leading: const Icon(Icons.logout),
                            child: const Text('Logout'),
                            onPressed: (ctx) {
                              widget.homeViewModel.authController.logout();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
        children: railChildren,
      );
    });
  }
}
