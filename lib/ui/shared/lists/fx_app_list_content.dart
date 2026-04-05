import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/boudaries.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_widget.dart';

class FxAppListContent<T extends HasModelStatus> extends StatelessWidget {
  const FxAppListContent({
    super.key,
    required this.screenSize,
    required this.isCardsView,
    required this.items,
    required this.columns,
    this.onItemClicked,
    this.statusSelector,
  });
  final ScreenSize screenSize;
  final bool isCardsView;
  final RxList<T> items;
  final List<AppTableColumn<T>> columns;
  final void Function(T item)? onItemClicked;
  final StatusVisual Function(T item)? statusSelector;

  StatusVisual _resolveStatus(T item) => statusSelector != null ? statusSelector!(item) : item.status;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Obx(() {
      return screenSize == ScreenSize.isLargeScreen || screenSize == ScreenSize.isMediumScreen
          ? (isCardsView
                ?
                  /// ----------------------------- Cards View -----------------------------
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: screenWidth > 1200 ? 4 : 3),
                    itemCount: items.length,
                    itemBuilder: (context, integer) {
                      var item = items[integer];
                      return MouseRegion(
                        cursor: onItemClicked != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: () => onItemClicked?.call(item),
                          child: SizedBox(
                            width: 307,
                            height: 355,
                            child: Card(
                              boxShadow: [BoxShadow(color: Colors.slate.shade300, blurRadius: 5, offset: Offset(0, 2))],
                              padding: EdgeInsets.zero,
                              key: ValueKey(item.id),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 100,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: _resolveStatus(item).gradient,
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                    ),
                                  ),
                                  for (var column in columns) column.buildCardPosition(column.buildCardContent(item)),
                                  Positioned(bottom: 60, left: 10, right: 10, child: Divider(thickness: 1, color: Colors.slate.shade300)),
                                ],
                              ),
                            ).marginAll(10),
                          ),
                        ),
                      );
                    },
                  )
                :
                  /// ----------------------------- Table View -----------------------------
                  CustomScrollView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.slate.shade200,
                            // color: FxColors.primary.withValues(alpha: 0.1),
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              for (var column in columns)
                                Expanded(
                                  child: SizedBox(
                                    height: 52,
                                    child: Center(
                                      child: Text(column.title, textAlign: TextAlign.center).textSmall(color: Colors.slate.shade600),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = items[index];
                          return GestureDetector(
                            onTap: () => onItemClicked?.call(item),
                            child: Container(
                              key: ValueKey(item.id),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.slate.shade300)),
                              ),
                              child: Row(
                                spacing: 10,
                                children: [
                                  for (var column in columns)
                                    Expanded(
                                      child: SizedBox(
                                        height: 52,
                                        child: Center(
                                          // child: column.builder(item, false, screenSize),
                                          child: column.buildTableCell(column.buildTableContent(item)),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }, childCount: items.length),
                      ),
                    ],
                  ))
          // : screenSize == ScreenSize.isMediumScreen
          // ? Center(child: Text('Tablet'))
          : ListView.builder(
              // crossAxisAlignment: WrapCrossAlignment.start,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, integer) {
                // for (var item in items)
                var item = items[integer];
                return GestureDetector(
                  onTap: () => onItemClicked?.call(item),
                  child: Card(
                    key: ValueKey(item.id),
                    boxShadow: [BoxShadow(color: Colors.slate.shade300, blurRadius: 5, offset: const Offset(0, 2))],
                    padding: EdgeInsets.zero,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: BoxBorder.fromLTRB(top: BorderSide(color: _resolveStatus(item).color, width: 4)),
                      ),
                      width: 376,
                      height: 163,
                      child: Stack(
                        children: [
                          for (var column in columns) column.buildCardPositionMobile(column.buildCardContentMobile(item)),
                          Positioned(top: 75, left: 20, right: 20, child: Divider(thickness: 1, color: Colors.slate.shade300)),
                        ],
                      ),
                    ),
                  ).marginOnly(bottom: Boudaries.spacing),
                );
              },
            );
    });
  }
}
