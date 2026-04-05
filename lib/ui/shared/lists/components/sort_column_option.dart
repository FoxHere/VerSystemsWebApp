/// Enum para direção de ordenação
enum SortDirection {
  ascending,
  descending,
}

/// Classe que representa uma opção de ordenação de coluna
class SortColumnOption {
  SortColumnOption({
    required this.columnTitle,
    this.direction = SortDirection.ascending,
  });

  final String columnTitle;
  SortDirection direction;

  /// Retorna o título formatado com indicador de direção
  String get displayTitle {
    final directionIcon = direction == SortDirection.ascending ? ' ↑' : ' ↓';
    return '$columnTitle$directionIcon';
  }

  /// Alterna a direção de ordenação
  void toggleDirection() {
    direction = direction == SortDirection.ascending
        ? SortDirection.descending
        : SortDirection.ascending;
  }

  /// Cria uma cópia com direção invertida
  SortColumnOption copyWithInvertedDirection() {
    return SortColumnOption(
      columnTitle: columnTitle,
      direction: direction == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortColumnOption &&
          runtimeType == other.runtimeType &&
          columnTitle == other.columnTitle &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(columnTitle, direction);
}
