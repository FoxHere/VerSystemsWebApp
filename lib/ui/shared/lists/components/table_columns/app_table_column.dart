import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';

abstract class AppTableColumn<T extends HasModelStatus> {
  AppTableColumn({required this.title});
  final String title;

  String formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  Widget buildCardContent(T item);
  Widget buildCardContentMobile(T item);
  Widget buildTableContent(T item);

  /// Posição no CARD (somente dados)
  Positioned buildCardPosition(Widget content);
  Positioned buildCardPositionMobile(Widget content);

  /// Conteúdo na TABELA
  Widget buildTableCell(Widget content);
}
