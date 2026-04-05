import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';

class AppTableColumnStatus<T extends HasModelStatus<StatusVisual>> extends AppTableColumn<T> {
  AppTableColumnStatus({required super.title, this.cardPosition, this.cardPositionMobile, this.dataSelector});
  final Positioned? Function(Widget content)? cardPosition;
  final Positioned? Function(Widget content)? cardPositionMobile;
  final StatusVisual Function(T item)? dataSelector;
  Widget buildStatusWidget(T item) {
    final status = dataSelector != null ? dataSelector!(item) : item.status;
    return Container(
      decoration: BoxDecoration(color: Colors.slate.shade100, borderRadius: BorderRadius.circular(5)),
      width: 90,
      height: 25,
      child: Center(child: Text(status.label).semiBold.xSmall(color: status.color)),
    );
  }

  @override
  Widget buildCardContent(T item) {
    return buildStatusWidget(item);
  }

  @override
  Widget buildCardContentMobile(T item) {
    return buildCardContent(item);
  }

  @override
  Widget buildTableContent(T item) {
    return buildStatusWidget(item);
  }

  @override
  Positioned buildCardPosition(Widget content) {
    final cardContent = SizedBox(width: 100, height: 30, child: content);
    return cardPosition != null ? cardPosition!.call(cardContent)! : Positioned(top: 15, left: 15, child: cardContent);
  }

  @override
  Positioned buildCardPositionMobile(Widget content) {
    final cardContent = SizedBox(width: 100, height: 30, child: content);
    return cardPositionMobile != null ? cardPositionMobile!.call(cardContent)! : Positioned(bottom: 22, left: 210, child: cardContent);
  }

  @override
  Widget buildTableCell(Widget content) {
    return content;
  }
}
