import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/components/status_widget/status_widget.dart';

enum ActivityStatusEnum { active, editing, inactive, done }

/// Adapta [ActivityStatusEnum] para [StatusVisual] para uso na tabela padrão de listas.
class ActivityStatusVisual implements StatusVisual {
  ActivityStatusVisual(this._status, {this.isTask = false});
  final ActivityStatusEnum _status;
  final bool isTask;

  @override
  Color get color {
    if (isTask && _status == ActivityStatusEnum.active) return Colors.orange;
    return _status.color;
  }

  @override
  Color get backgroundColor {
    if (isTask && _status == ActivityStatusEnum.active) return Colors.orange.withValues(alpha: 0.3);
    return _status.color.withValues(alpha: 0.3);
  }

  @override
  String get label {
    if (isTask && _status == ActivityStatusEnum.active) return 'Pendente';
    return _status.label;
  }

  @override
  LinearGradient get gradient {
    if (isTask && _status == ActivityStatusEnum.active) {
      return LinearGradient(
        colors: [Colors.orange.withValues(alpha: 0.5), Colors.orange.withValues(alpha: 0.2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [_status.color.withValues(alpha: 0.5), _status.color.withValues(alpha: 0.2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ActivityStatusVisual && _status == other._status;

  @override
  int get hashCode => _status.hashCode;
}

extension ActivityStatusEnumExtension on ActivityStatusEnum {
  static ActivityStatusEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return ActivityStatusEnum.active;
      case 'editing':
        return ActivityStatusEnum.editing;
      case 'inactive':
        return ActivityStatusEnum.inactive;
      case 'done':
        return ActivityStatusEnum.done;
      default:
        return ActivityStatusEnum.inactive;
    }
  }

  static ActivityStatusEnum fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'ativo':
        return ActivityStatusEnum.active;
      case 'em edição':
        return ActivityStatusEnum.editing;
      case 'inativo':
        return ActivityStatusEnum.inactive;
      case 'finalizado':
        return ActivityStatusEnum.done;
      default:
        return ActivityStatusEnum.inactive;
    }
  }

  String get label => switch (this) {
    ActivityStatusEnum.active => 'Ativo',
    ActivityStatusEnum.editing => 'Em edição',
    ActivityStatusEnum.inactive => 'Inativo',
    ActivityStatusEnum.done => 'Finalizado',
  };

  IconData get icon => switch (this) {
    ActivityStatusEnum.active => Symbols.rocket_launch,
    ActivityStatusEnum.editing => Symbols.edit_document,
    ActivityStatusEnum.inactive => Symbols.block,
    ActivityStatusEnum.done => Symbols.task_alt,
  };

  Color get color => switch (this) {
    ActivityStatusEnum.done => Colors.green,
    ActivityStatusEnum.inactive => Colors.slate[600],
    ActivityStatusEnum.editing => Colors.orange,
    ActivityStatusEnum.active => Colors.blue,
  };
}

class ActivityStatus extends StatelessWidget {
  final ActivityStatusEnum status;
  const ActivityStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final visual = ActivityStatusVisual(status);

    return StatusWidget<ActivityStatusVisual>(status: visual, icon: status.icon);
  }
}

// class ActivityStatusWidget extends StatelessWidget {
//   final String label;
//   final IconData icon;

//   const ActivityStatusWidget({super.key, required this.label, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     final ActivityStatusEnum variant = ActivityStatusEnumExtension.fromLabel(label);
//     final color = switch (variant) {
//       ActivityStatusEnum.done => ActivityStatusEnum.done.color,
//       ActivityStatusEnum.inactive => ActivityStatusEnum.inactive.color,
//       ActivityStatusEnum.editing => ActivityStatusEnum.editing.color,
//       ActivityStatusEnum.active => ActivityStatusEnum.active.color,
//     };

//     return Container(
//       width: 100,
//       // padding: FxTheme.smallPadding / 2,
//       decoration: BoxDecoration(
//         // borderRadius: FxTheme.borderRadiusAll / 2,
//         color: color.withValues(alpha: 0.2),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         spacing: 7,
//         children: [
//           Icon(icon, color: color, size: 16),
//           Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color)),
//         ],
//       ),
//     );
//   }
// }
