import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';

class AppTableColumnCreatedBy<T extends HasModelStatus> extends AppTableColumn<T> {
  AppTableColumnCreatedBy({
    required super.title,
    required this.dataSelector,
    required this.updatedAtSelector,
    this.cardPosition,
    this.cardPositionMobile,
  });

  final UserModel? Function(T item) dataSelector;
  final String Function(T item) updatedAtSelector;
  final Positioned? Function(Widget content)? cardPosition;
  final Positioned? Function(Widget content)? cardPositionMobile;

  Widget buildAvatar(T item, bool isTableRow) {
    final user = dataSelector(item);
    final updatedAtFormatted = formatDate(updatedAtSelector(item));
    return SizedBox(
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isTableRow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Avatar(
            provider: user?.profileImage?.downloadUrl != null ? NetworkImage(user!.profileImage!.downloadUrl!) : null,
            size: 35,
            backgroundColor: Colors.purple,
            initials: Avatar.getInitials(user!.name),
          ),
          Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: isTableRow ? .center : .start,
            children: [
              Text(dataSelector(item)!.name).textSmall(color: Colors.slate.shade600),
              if (!isTableRow)
                Row(
                  spacing: 5,
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .center,
                  children: [
                    Icon(Symbols.calendar_clock, size: 14, color: Colors.slate),
                    Text(updatedAtFormatted, style: TextStyle(fontSize: 10, color: Colors.slate)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget buildCardContent(T item) {
    return buildAvatar(item, false);
  }

  @override
  Widget buildCardContentMobile(T item) {
    return Container(
      padding: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.slate.shade300, width: 1)),
      ),
      child: buildCardContent(item),
    );
  }

  @override
  Widget buildTableContent(T item) {
    return buildAvatar(item, true);
  }

  @override
  Positioned buildCardPosition(Widget content) {
    final cardContent = content;
    return cardPosition != null ? cardPosition!.call(cardContent)! : Positioned(bottom: 15, left: 15, child: cardContent);
  }

  @override
  Positioned buildCardPositionMobile(Widget content) {
    final cardContent = content;
    return cardPositionMobile != null ? cardPositionMobile!.call(cardContent)! : Positioned(bottom: 20, left: 20, child: content);
  }

  @override
  Widget buildTableCell(Widget content) {
    return content;
  }
}
