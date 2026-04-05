import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';

class AppTableColumnUpdatedAt<T extends HasModelStatus> extends AppTableColumn<T> {
  AppTableColumnUpdatedAt({
    required super.title,
    required this.dataSelector,
    this.cardPosition,
    this.cardPositionMobile,
    this.needToShowOnCard = true,
  });

  final String Function(T) dataSelector;
  final bool needToShowOnCard;
  final Positioned? Function(Widget content)? cardPosition;
  final Positioned? Function(Widget content)? cardPositionMobile;
  @override
  Widget buildCardContent(T item) {
    final date = formatDate(dataSelector(item));
    return Text(date.toString(), style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis));
  }

  @override
  Widget buildCardContentMobile(T item) {
    return buildCardContent(item);
  }

  @override
  Widget buildTableContent(T item) {
    final date = formatDate(dataSelector(item));
    return Text(date.toString()).xSmall(color: Colors.slate.shade500);
  }

  @override
  Positioned buildCardPosition(Widget content) {
    final cardContent = needToShowOnCard
        ? SizedBox(
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Symbols.calendar_clock, size: 14, color: Colors.slate),
                content,
              ],
            ),
          )
        : SizedBox.shrink();
    return cardPosition != null ? cardPosition!.call(cardContent)! : Positioned(bottom: 10, left: 15, child: cardContent);
  }

  @override
  Widget buildTableCell(Widget content) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Symbols.calendar_clock, size: 16, color: Colors.slate),
        content,
      ],
    );
  }

  @override
  Positioned buildCardPositionMobile(Widget content) {
    final cardContent = needToShowOnCard ? content : SizedBox.shrink();
    return cardPositionMobile != null ? cardPositionMobile!.call(cardContent)! : Positioned(bottom: 20, left: 20, child: cardContent);
  }
}
