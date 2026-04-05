import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';

class AppTableColumnTitle<T extends HasModelStatus> extends AppTableColumn<T> {
  AppTableColumnTitle({required super.title, required this.dataSelector, this.cardPosition, this.cardPositionMobile});

  final String Function(T) dataSelector;
  final Positioned? Function(Widget content)? cardPosition;
  final Positioned? Function(Widget content)? cardPositionMobile;
  @override
  Widget buildCardContent(T item) {
    return Tooltip(
      tooltip: TooltipContainer(
        child: Text(dataSelector(item), style: TextStyle(color: Colors.white)),
      ).call,
      child: Text(dataSelector(item), maxLines: 1, overflow: TextOverflow.ellipsis).medium(color: Colors.slate.shade600),
    );
  }

  @override
  Widget buildCardContentMobile(T item) {
    return buildCardContent(item);
  }

  @override
  Widget buildTableContent(T item) {
    return Tooltip(
      tooltip: TooltipContainer(
        child: Text(dataSelector(item), style: TextStyle(color: Colors.white)),
      ).call,
      child: Text(dataSelector(item), maxLines: 1, overflow: TextOverflow.ellipsis).textSmall(color: Colors.slate.shade500),
    );
  }

  @override
  Positioned buildCardPosition(Widget content) {
    final cardContent = content;
    return cardPosition != null ? cardPosition!.call(cardContent)! : Positioned(top: 110, left: 15, right: 40, child: cardContent);
  }

  @override
  Positioned buildCardPositionMobile(Widget content) {
    final cardContent = content;
    return cardPositionMobile != null ? cardPositionMobile!.call(cardContent)! : Positioned(top: 20, left: 20, child: cardContent);
  }

  @override
  Widget buildTableCell(Widget content) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: content);
  }
}
