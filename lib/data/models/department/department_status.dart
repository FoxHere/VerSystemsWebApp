import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/components/status_widget/status_widget.dart';

enum DepartmentStatusEnum { active, inactive }

class DepartmentStatusVisual implements StatusVisual {
  DepartmentStatusVisual(this._status);

  final DepartmentStatusEnum _status;

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
  bool operator ==(Object other) => identical(this, other) || other is DepartmentStatusVisual && _status == other._status;

  @override
  int get hashCode => _status.hashCode;
}

extension DepartmentStatusEnumExtension on DepartmentStatusEnum {
  static DepartmentStatusEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return DepartmentStatusEnum.active;
      case 'inactive':
        return DepartmentStatusEnum.inactive;
      default:
        return DepartmentStatusEnum.inactive;
    }
  }

  static DepartmentStatusEnum fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'ativo':
        return DepartmentStatusEnum.active;
      case 'inativo':
        return DepartmentStatusEnum.inactive;
      default:
        return DepartmentStatusEnum.inactive;
    }
  }

  String get label => switch (this) {
    DepartmentStatusEnum.active => 'Ativo',
    DepartmentStatusEnum.inactive => 'Inativo',
  };

  IconData get icon => switch (this) {
    DepartmentStatusEnum.active => Symbols.rocket_launch,
    DepartmentStatusEnum.inactive => Symbols.block,
  };

  Color get color => switch (this) {
    DepartmentStatusEnum.inactive => Colors.slate[600],
    DepartmentStatusEnum.active => Colors.blue,
  };
}

class DepartmentStatusWidget extends StatelessWidget {
  final DepartmentStatusEnum status;
  const DepartmentStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final visual = DepartmentStatusVisual(status);
    return switch (status) {
      DepartmentStatusEnum.active => StatusWidget<DepartmentStatusVisual>(status: visual, icon: status.icon),
      DepartmentStatusEnum.inactive => StatusWidget<DepartmentStatusVisual>(status: visual, icon: status.icon),
    };
  }
}
