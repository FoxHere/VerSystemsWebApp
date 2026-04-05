import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/components/status_widget/status_widget.dart';

enum CompanyStatusEnum { active, inactive }

/// StatusVisual padrão para entidades de lista que não possuem status (ex: cliente, empresa, usuário).
/// Usado para permitir reutilizar [FxAppListContent] e [FxAppListWidget] em todas as listas.
class CompanyStatusVisual implements StatusVisual {
  CompanyStatusVisual(this._status);

  final CompanyStatusEnum _status;

  @override
  Color get color => _status.color;

  @override
  Color get backgroundColor => _status.color.withValues(alpha: 0.3);

  @override
  String get label => _status.label;

  @override
  LinearGradient get gradient => LinearGradient(
    colors: [_status.color.withValues(alpha: 0.5), _status.color.withValues(alpha: 0.2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || other is CompanyStatusVisual && _status == other._status;

  @override
  int get hashCode => _status.hashCode;
}

extension CompanyStatusEnumExtension on CompanyStatusEnum {
  static CompanyStatusEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return CompanyStatusEnum.active;
      case 'inactive':
        return CompanyStatusEnum.inactive;
      default:
        return CompanyStatusEnum.inactive;
    }
  }

  static CompanyStatusEnum fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'ativo':
        return CompanyStatusEnum.active;
      case 'inativo':
        return CompanyStatusEnum.inactive;
      default:
        return CompanyStatusEnum.inactive;
    }
  }

  String get label => switch (this) {
    CompanyStatusEnum.active => 'Ativo',
    CompanyStatusEnum.inactive => 'Inativo',
  };

  IconData get icon => switch (this) {
    CompanyStatusEnum.active => Symbols.rocket_launch,
    CompanyStatusEnum.inactive => Symbols.block,
  };

  Color get color => switch (this) {
    CompanyStatusEnum.inactive => Colors.slate[600],
    CompanyStatusEnum.active => Colors.blue,
  };
}

class ActivityStatus extends StatelessWidget {
  final CompanyStatusEnum status;
  const ActivityStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final visual = CompanyStatusVisual(status);
    return switch (status) {
      CompanyStatusEnum.active => StatusWidget<CompanyStatusVisual>(status: visual, icon: status.icon),
      CompanyStatusEnum.inactive => StatusWidget<CompanyStatusVisual>(status: visual, icon: status.icon),
    };
  }
}
