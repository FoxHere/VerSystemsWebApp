import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';

class AppTableColumnCreatedAt<T extends HasModelStatus> extends AppTableColumn<T> {
  AppTableColumnCreatedAt({required super.title, required this.dataSelector, this.cardPosition, this.cardPositionMobile});

  final String Function(T) dataSelector;
  final Positioned? Function(Widget content)? cardPosition;
  final Positioned? Function(Widget content)? cardPositionMobile;
  @override
  Widget buildCardContent(T item) {
    final date = formatDate(dataSelector(item));
    return Text(date, style: TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis));
  }

  @override
  Widget buildCardContentMobile(T item) {
    return buildCardContent(item);
  }

  @override
  Widget buildTableContent(T item) {
    final date = formatDate(dataSelector(item));
    return Text(date).textSmall(color: Colors.slate.shade500);
  }

  @override
  Positioned buildCardPosition(Widget content) {
    final cardContent = SizedBox(
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.calendar_month, size: 18, color: Colors.black),
          content,
        ],
      ),
    );
    return cardPosition != null ? cardPosition!.call(cardContent)! : Positioned(bottom: 10, left: 15, child: cardContent);
  }

  @override
  Widget buildTableCell(Widget content) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Symbols.calendar_month, size: 16, color: Colors.slate),
        content,
      ],
    );
  }

  @override
  Positioned buildCardPositionMobile(Widget content) {
    final cardContent = SizedBox(
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.calendar_month, size: 18, color: Colors.black),
          content,
        ],
      ),
    );
    return cardPositionMobile != null ? cardPositionMobile!.call(cardContent)! : Positioned(bottom: 10, left: 15, child: cardContent);
  }
}
