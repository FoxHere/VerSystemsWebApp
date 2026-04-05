import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';

class AppTableColumnWidget<T extends HasModelStatus> extends AppTableColumn<T> {
  AppTableColumnWidget({
    required super.title,
    required this.dataSelector,
    this.cardPosition,
    this.cardPositionMobile,
    this.tableContent,
    this.cardContent,
  });

  final Widget Function(T) dataSelector;
  final Positioned? Function(Widget content)? cardPosition;
  final Positioned? Function(Widget content)? cardPositionMobile;
  final Widget? Function(Widget item)? tableContent;
  final Widget? Function(Widget item)? cardContent;

  @override
  Widget buildCardContent(T item) {
    return cardContent != null ? cardContent!.call(dataSelector(item))! : dataSelector(item);
  }

  @override
  Widget buildCardContentMobile(T item) {
    return buildCardContent(item);
  }

  @override
  Widget buildTableContent(T item) {
    return dataSelector(item);
  }

  @override
  Positioned buildCardPosition(Widget content) {
    final carinternalCardContent = content;
    return cardPosition != null ? cardPosition!.call(carinternalCardContent)! : Positioned(bottom: 15, left: 30, child: carinternalCardContent);
  }

  @override
  Positioned buildCardPositionMobile(Widget content) {
    final carinternalCardContent = SizedBox(width: 300, height: 50, child: content);
    return cardPositionMobile != null
        ? cardPositionMobile!.call(carinternalCardContent)!
        : Positioned(top: 100, left: 30, child: carinternalCardContent);
  }

  @override
  Widget buildTableCell(Widget content) {
    return tableContent != null ? tableContent!.call(content)! : content;
  }

  // @override
  // Widget builder(T item, bool isCardsView, ScreenSize screenSize) {
  //   return dataSelector(item);
  // }
}
