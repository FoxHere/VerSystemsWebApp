import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/app_table_column.dart';

sealed class AppTableColumnAction {
  const AppTableColumnAction({required this.label, required this.onPressed, required this.icon});
  final String label;
  final ContextedCallback? onPressed;
  final IconData icon;
}

class AppTableColumnActionPress extends AppTableColumnAction {
  const AppTableColumnActionPress({required super.icon, required super.label, required super.onPressed});
}

class AppTableColumnSwitchAction extends AppTableColumnAction {
  const AppTableColumnSwitchAction({
    required super.label,
    required super.onPressed,
    required this.value,
    required super.icon,
    this.labelTrue,
    this.labelFalse,
    this.onChanged,
  });
  final bool value;
  final String? labelTrue;
  final String? labelFalse;
  final Function(bool value)? onChanged;
}

class AppTableColumnActions<T extends HasModelStatus> extends AppTableColumn<T> {
  AppTableColumnActions({required super.title, required this.dataSelector, this.cardPosition, this.cardPositionMobile});

  final List<AppTableColumnAction> Function(T) dataSelector;
  final Positioned? Function(Widget content)? cardPosition;
  final Positioned? Function(Widget content)? cardPositionMobile;
  @override
  Widget buildCardContent(T item) {
    return Builder(
      builder: (context) {
        return IconButton.ghost(
          icon: Icon(Symbols.more_vert),
          onPressed: () {
            showDropdown(
              context: context,
              builder: (context) {
                return DropdownMenu(
                  children: dataSelector(item).map((e) {
                    if (e is AppTableColumnActionPress) {
                      return MenuButton(
                        onPressed: e.onPressed,
                        child: Row(
                          spacing: 10,
                          children: [
                            Icon(e.icon, size: 16, color: Colors.black),
                            Expanded(child: Text(e.label)),
                          ],
                        ),
                      );
                    } else if (e is AppTableColumnSwitchAction) {
                      return MenuButton(
                        onPressed: (context) {
                          e.onChanged?.call(!e.value);
                          e.onPressed?.call(context);
                        },
                        child: Row(
                          spacing: 10,
                          children: [
                            Icon(e.icon, size: 16, color: Colors.black),
                            Expanded(child: Text(e.label)),
                            IgnorePointer(
                              child: Switch(value: e.value, onChanged: (value) {}),
                            ),
                          ],
                        ),
                      );
                    }
                    return MenuButton(
                      onPressed: e.onPressed,
                      child: Row(
                        spacing: 10,
                        children: [
                          Icon(e.icon, size: 16, color: Colors.black),
                          Expanded(child: Text(e.label)),
                        ],
                      ),
                    );
                  }).toList(),

                  // onChanged: (value) {
                  //   value?.onPressed();
                  // },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildCardContentMobile(T item) {
    return buildCardContent(item);
  }

  @override
  Widget buildTableContent(T item) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: dataSelector(item).map((e) {
            if (e is AppTableColumnSwitchAction) {
              return Switch(value: e.value, onChanged: (value) => e.onChanged?.call(value));
            }
            return IconButton.ghost(
              onPressed: () => e.onPressed?.call(context),
              icon: Icon(e.icon, size: 18, color: Colors.slate),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Positioned buildCardPosition(Widget content) {
    final cardContent = content;
    return cardPosition != null ? cardPosition!.call(cardContent)! : Positioned(top: 110, right: 10, child: cardContent);
  }

  @override
  Positioned buildCardPositionMobile(Widget content) {
    final cardContent = content;
    return cardPositionMobile != null ? cardPositionMobile!.call(cardContent)! : Positioned(top: 20, right: 15, child: cardContent);
  }

  @override
  Widget buildTableCell(Widget content) {
    return content;
  }
}
