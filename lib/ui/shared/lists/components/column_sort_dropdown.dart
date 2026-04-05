import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Dropdown para seleção de coluna para ordenação
class ColumnSortDropdown extends StatefulWidget {
  const ColumnSortDropdown({
    super.key,
    required this.columns,
    required this.onColumnSelected,
    this.selectedColumn,
    this.whenEmpty = 'Ordenar por',
  });

  /// Lista de títulos das colunas disponíveis
  final List<String> columns;

  /// Callback chamado quando uma coluna é selecionada
  /// Recebe o título da coluna selecionada
  final Function(String columnTitle) onColumnSelected;

  /// Coluna atualmente selecionada (opcional)
  final String? selectedColumn;

  /// Texto exibido quando nenhuma coluna está selecionada
  final String whenEmpty;

  @override
  State<ColumnSortDropdown> createState() => _ColumnSortDropdownState();
}

class _ColumnSortDropdownState extends State<ColumnSortDropdown> {
  String? _selectedColumn;
  MenuController? _menuController;

  @override
  void initState() {
    super.initState();
    _selectedColumn = widget.selectedColumn;
  }

  @override
  void didUpdateWidget(ColumnSortDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColumn != oldWidget.selectedColumn) {
      _selectedColumn = widget.selectedColumn;
    }
  }

  void _handleColumnSelection(String columnTitle, MenuController controller) {
    setState(() {
      _selectedColumn = columnTitle;
    });
    controller.close();
    widget.onColumnSelected(columnTitle);
  }

  @override
  Widget build(BuildContext context) {
    final textToShow = _selectedColumn ?? widget.whenEmpty;

    return MenuAnchor(
      crossAxisUnconstrained: false,
      style: MenuStyle(
        fixedSize: WidgetStateProperty.resolveWith((states) {
          return const Size(200, 300);
        }),
        padding: WidgetStateProperty.resolveWith((states) {
          return EdgeInsets.zero;
        }),
      ),
      builder: (context, controller, _) {
        _menuController = controller;
        return InkWell(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: Container(
            constraints: const BoxConstraints(minWidth: 120, maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue.shade300,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  Symbols.sort,
                  size: 18,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    textToShow,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        );
      },
      menuChildren: widget.columns.map((columnTitle) {
        final isSelected = _selectedColumn == columnTitle;
        return InkWell(
          onTap: () {
            if (_menuController != null) {
              _handleColumnSelection(columnTitle, _menuController!);
            }
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    columnTitle,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Symbols.check,
                    size: 18,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
