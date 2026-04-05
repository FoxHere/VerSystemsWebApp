import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';

class AppTableColumnIconText<T extends HasModelStatus> extends AppTableColumn<T> {
  AppTableColumnIconText({required this.icon, required super.title, required this.dataSelector, this.cardPosition});

  final IconData icon;
  final String Function(T) dataSelector;
  final Positioned? Function(Widget content)? cardPosition;

  @override
  Widget buildCardContent(T item) {
    return Text(dataSelector(item)).textSmall(color: Colors.slate.shade500);
  }

  @override
  Widget buildCardContentMobile(T item) {
    return buildCardContent(item);
  }

  @override
  Widget buildTableContent(T item) {
    return Text(dataSelector(item), maxLines: 2, overflow: TextOverflow.ellipsis).textSmall(color: Colors.slate.shade500);
  }

  @override
  Positioned buildCardPosition(Widget content) {
    final cardContent = Column(
      mainAxisAlignment: .start,
      children: [
        Icon(icon, size: 16, color: Colors.slate),
        content,
      ],
    );
    return cardPosition != null ? cardPosition!.call(cardContent)! : Positioned(bottom: 15, right: 15, child: cardContent);
  }

  @override
  Widget buildTableCell(Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.slate),
          content,
        ],
      ),
    );
  }

  @override
  Positioned buildCardPositionMobile(Widget content) {
    final cardContent = SizedBox(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.black),
          content,
        ],
      ),
    );
    return cardPosition != null ? cardPosition!.call(cardContent)! : Positioned(bottom: 20, right: 20, child: cardContent);
  }
}
