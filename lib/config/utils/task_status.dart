import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';

enum TaskStatusEnum { active, editing, inactive, done }

extension TaskStatusEnumExtension on TaskStatusEnum {
  static TaskStatusEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return TaskStatusEnum.active;
      case 'editing':
        return TaskStatusEnum.editing;
      case 'inactive':
        return TaskStatusEnum.inactive;
      case 'done':
        return TaskStatusEnum.done;
      default:
        return TaskStatusEnum.inactive;
    }
  }

  static TaskStatusEnum fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'pendente':
        return TaskStatusEnum.active;
      case 'preenchendo':
        return TaskStatusEnum.editing;
      case 'inativo':
        return TaskStatusEnum.inactive;
      case 'finalizado':
        return TaskStatusEnum.done;
      default:
        return TaskStatusEnum.inactive;
    }
  }

  String get label => switch (this) {
    TaskStatusEnum.active => 'Pendente',
    TaskStatusEnum.editing => 'Preenchendo',
    TaskStatusEnum.inactive => 'Inativo',
    TaskStatusEnum.done => 'Finalizado',
  };

  IconData get icon => switch (this) {
    TaskStatusEnum.active => Symbols.flag_2,
    TaskStatusEnum.editing => Symbols.edit_document,
    TaskStatusEnum.inactive => Symbols.block,
    TaskStatusEnum.done => Symbols.editor_choice,
  };

  Color get color => switch (this) {
    TaskStatusEnum.active => Colors.red,
    TaskStatusEnum.editing => Colors.orange,
    TaskStatusEnum.inactive => Colors.grey[600]!,
    TaskStatusEnum.done => Colors.green,
  };
}

class TaskStatus extends StatelessWidget {
  final ActivityStatusEnum status;
  const TaskStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ActivityStatusEnum.active => StatusWidget(label: TaskStatusEnum.active.label, icon: TaskStatusEnum.active.icon),
      ActivityStatusEnum.editing => StatusWidget(label: TaskStatusEnum.editing.label, icon: TaskStatusEnum.editing.icon),
      ActivityStatusEnum.inactive => StatusWidget(label: TaskStatusEnum.inactive.label, icon: TaskStatusEnum.inactive.icon),
      ActivityStatusEnum.done => StatusWidget(label: TaskStatusEnum.done.label, icon: TaskStatusEnum.done.icon),
    };
  }
}

class StatusWidget extends StatelessWidget {
  final String label;
  final IconData icon;

  const StatusWidget({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final TaskStatusEnum variant = TaskStatusEnumExtension.fromLabel(label);
    final color = switch (variant) {
      TaskStatusEnum.done => TaskStatusEnum.done.color,
      TaskStatusEnum.inactive => TaskStatusEnum.inactive.color,
      TaskStatusEnum.editing => TaskStatusEnum.editing.color,
      TaskStatusEnum.active => TaskStatusEnum.active.color,
    };

    return Container(
      width: 110,
      // padding: FxTheme.smallPadding / 2,
      decoration: BoxDecoration(
        // borderRadius: FxTheme.borderRadiusAll / 2,
        color: color.withValues(alpha: 0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 7,
        children: [
          Icon(icon, color: color, size: 16),
          Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color)),
        ],
      ),
    );
  }
}
