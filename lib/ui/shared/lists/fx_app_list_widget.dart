import 'dart:async';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/boudaries.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/app_page_status_builder.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';
import 'package:versystems_app/ui/shared/lists/components/list_loading.dart';
import 'package:versystems_app/ui/shared/lists/components/sort_column_option.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_content.dart';

enum ScreenSize { isLargeScreen, isMediumScreen, isSmallScreen }

class FxAppListWidget<T extends HasModelStatus> extends StatefulWidget {
  const FxAppListWidget({
    super.key,
    required this.listTitle,
    this.listSubtitle,
    required this.items,
    required this.columns,
    required this.screenSize,
    required this.onViewChange,
    required this.searchTextFunction,
    required this.onRefresh,
    this.onNewItem,
    this.onItemClicked,
    required this.statusFilterFunction,
    this.statusList = const [],
    this.showStatusTab = false,
    this.showStatusSelect = false,
    required this.pageStatus,
    this.emptyAction,
    this.onSortColumn,
    this.newItemLabel = 'Novo item',
    this.searchHint = 'Buscar...',
    this.statusSelector,
  });

  final String listTitle;
  final String? listSubtitle;
  final RxList<T> items;
  final List<AppTableColumn<T>> columns;
  final ScreenSize screenSize;
  final Function(bool) onViewChange;
  final Function(String) searchTextFunction;
  final Function() onRefresh;
  final Function()? onNewItem;
  final Function(T item)? onItemClicked;
  final Function(String status) statusFilterFunction;
  final List<StatusVisual> statusList;
  final bool showStatusTab;
  final bool showStatusSelect;
  final Rx<PageStatus> pageStatus;
  final Widget? emptyAction;
  final Function(SortColumnOption sortOption)? onSortColumn;
  final StatusVisual Function(T item)? statusSelector;

  /// Texto do botão de novo item (ex: "Novo formulário", "Novo cliente").
  final String newItemLabel;

  /// Placeholder do campo de busca.
  final String searchHint;

  @override
  State<FxAppListWidget<T>> createState() => _FxAppListWidgetState2<T>();
}

class _FxAppListWidgetState2<T extends HasModelStatus> extends State<FxAppListWidget<T>> {
  final isCardsView = true.obs;
  final tabIndex = 0.obs;
  late final List<StatusTab> tabs;
  final statusTabsItemsCounts = <StatusVisual?, int>{}.obs;
  int _lastSignature = -1;
  Worker? _itemsWorker;
  Timer? _debounce;

  // Estado para ordenação (comentado)

  @override
  void initState() {
    super.initState();

    /// Inicia a criação das tabs de acordo com  o status list
    tabs = [StatusTab(label: 'Todos', status: null), ...widget.statusList.map((status) => StatusTab(label: status.label, status: status))];
    // Observa mudanças na lista para recalcular contadores automaticamente
    _itemsWorker = ever(widget.items, (_) {
      if (mounted) {
        _recalcCounts();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _itemsWorker?.dispose();
    super.dispose();
  }

  void _recalcCountsIfNeeded(List<T> items) {
    if (!mounted) return;

    // assinatura simples pra evitar recalcular à toa e evitar loops
    final signature = Object.hashAll([items.length, ...widget.statusList.map((s) => items.where((e) => e.status == s).length)]);

    if (signature == _lastSignature) return;
    _lastSignature = signature;

    final map = <StatusVisual?, int>{};
    map[null] = items.where((item) => widget.statusList.contains(item.status)).length;
    for (final status in widget.statusList) {
      map[status] = items.where((item) => item.status == status).length;
    }

    // importante: isso acontece fora do build (init post-frame)
    statusTabsItemsCounts.assignAll(map);
  }

  void _recalcCounts() {
    if (!mounted) return;
    _recalcCountsIfNeeded(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.screenSize == ScreenSize.isLargeScreen ? 1300 : 1200),
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(scrollbars: false, overscroll: false),
          child: CustomScrollView(
            slivers: [
              // ---------------------- Header ----------------------
              SliverToBoxAdapter(
                child: Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: widget.screenSize == ScreenSize.isSmallScreen ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: widget.screenSize == ScreenSize.isSmallScreen ? .center : .start,
                      children: [
                        Text(widget.listTitle).h3(),
                        if (widget.listSubtitle != null) Text(widget.listSubtitle!).light(color: Colors.slate),
                      ],
                    ),

                    // ---------------------- Actions ----------------------
                    if (widget.screenSize == ScreenSize.isLargeScreen || widget.screenSize == ScreenSize.isMediumScreen)
                      Expanded(
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // ---------------------- Status Filter ----------------------
                            if (widget.showStatusSelect)
                              if (!widget.showStatusTab)
                                SizedBox(
                                  width: 200,
                                  child: MultiSelect<StatusVisual>(
                                    value: [],
                                    placeholder: const Text('Status'),
                                    itemBuilder: (context, val) => Text(val.label),
                                    onChanged: (values) => widget.statusFilterFunction(values?.map((v) => v.label).join(',') ?? ''),
                                    popup: (context) => SelectPopup(
                                      items: SelectItemList(
                                        children: widget.statusList
                                            .map((status) => SelectItemButton(value: status, child: Text(status.label)))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ),
                            // ---------------------- New Item Button ----------------------
                            if (widget.onNewItem != null)
                              PrimaryButton(leading: const Icon(Symbols.add), onPressed: widget.onNewItem!, child: Text(widget.newItemLabel)),
                          ],
                        ),
                      ),
                  ],
                ).paddingAll(Boudaries.spacing),
              ),

              // ---------------------- Page Status Builder ----------------------
              SliverToBoxAdapter(
                child: Row(
                  spacing: Boudaries.spacing,
                  mainAxisAlignment: widget.screenSize == ScreenSize.isSmallScreen ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                  children: [
                    // ---------------------- TABS ----------------------
                    if (widget.showStatusTab)
                      Obx(() {
                        return Tabs(
                          index: tabIndex.value,
                          onChanged: (tab) => tabIndex.value = tab,
                          children: tabs.map((tab) {
                            final count = statusTabsItemsCounts[tab.status] ?? 0;
                            return TabItem(
                              child: Row(
                                spacing: 6,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(tab.label),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.slate[100], borderRadius: BorderRadius.circular(5)),
                                    child: Text(count.toString(), style: const TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    // ---------------------- Search Bar ----------------------
                    if (widget.screenSize == ScreenSize.isLargeScreen || widget.screenSize == ScreenSize.isMediumScreen)
                      Row(
                        spacing: 10,
                        children: [
                          SizedBox(
                            width: 250,
                            child: TextField(
                              onChanged: (text) {
                                if (_debounce?.isActive ?? false) _debounce!.cancel();
                                _debounce = Timer(const Duration(milliseconds: 500), () {
                                  widget.searchTextFunction(text);
                                });
                              },
                              autocorrect: true,
                              hintText: widget.searchHint,
                              placeholder: Text(widget.searchHint).light(color: Colors.slate.shade400),
                              features: [
                                InputFeature.clear(),
                                InputFeature.leading(Icon(Symbols.search, color: Colors.slate.shade400)),
                              ],
                            ),
                          ),
                          // ---------------------- Buttons Actions ----------------------
                          IconButton.outline(onPressed: widget.onRefresh, icon: Icon(Symbols.refresh)),
                          Obx(() {
                            return ButtonGroup(
                              children: [
                                IconButton(
                                  onPressed: () => isCardsView.value = true,
                                  icon: Icon(Symbols.grid_view, color: isCardsView.value ? Colors.white : Colors.slate, size: 18),
                                  variance: isCardsView.value ? ButtonVariance.primary : ButtonVariance.outline,
                                ),
                                IconButton(
                                  onPressed: () => isCardsView.value = false,
                                  icon: Icon(Symbols.list, color: !isCardsView.value ? Colors.white : Colors.slate),
                                  variance: !isCardsView.value ? ButtonVariance.primary : ButtonVariance.outline,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                  ],
                ).paddingSymmetric(horizontal: Boudaries.spacing),
              ),
              if (widget.screenSize == ScreenSize.isSmallScreen)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: Boudaries.spacing * 2, right: Boudaries.spacing * 2, top: Boudaries.spacing),
                    child: TextField(
                      onChanged: (text) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          widget.searchTextFunction(text);
                        });
                      },
                      autocorrect: true,
                      hintText: widget.searchHint,
                      features: [
                        InputFeature.clear(),
                        InputFeature.leading(Icon(Symbols.search, color: Colors.slate.shade400)),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Obx(() {
                  return AppPageStatusBuilder<List<T>>(
                    pageStatus: widget.pageStatus.value,
                    loadingWidget: ListLoading(),
                    successBuilder: (objects) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // ---------------------- List ----------------------
                          if (widget.showStatusTab)
                            Obx(() {
                              final currentTab = tabs.isNotEmpty && tabIndex.value < tabs.length ? tabs[tabIndex.value] : null;
                              final filteredItems = currentTab?.status == null
                                  ? widget.items.where((item) => widget.statusList.contains(item.status)).toList().obs
                                  : widget.items.where((item) => item.status == currentTab!.status).toList().obs;
                              return FxAppListContent<T>(
                                screenSize: widget.screenSize,
                                isCardsView: isCardsView.value,
                                items: filteredItems,
                                columns: widget.columns,
                                onItemClicked: widget.onItemClicked,
                                statusSelector: widget.statusSelector,
                              ).paddingAll(Boudaries.spacing);
                            }),
                          if (!widget.showStatusTab)
                            Obx(() {
                              return FxAppListContent<T>(
                                screenSize: widget.screenSize,
                                isCardsView: isCardsView.value,
                                items: widget.items,
                                columns: widget.columns,
                                onItemClicked: widget.onItemClicked,
                              ).paddingAll(Boudaries.spacing);
                            }),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusTab {
  StatusTab({required this.label, this.status});
  final String label;
  final StatusVisual? status;
  // final int count;
}
