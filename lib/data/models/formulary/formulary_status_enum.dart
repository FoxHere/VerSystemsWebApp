import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/components/status_widget/status_widget.dart';

enum FormStatusEnum { active, editing, inactive }

/// Adapta [ActivityStatusEnum] para [StatusVisual] para uso na tabela padrão de listas.
class FormStatusVisual implements StatusVisual {
  FormStatusVisual(this._status);
  final FormStatusEnum _status;

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
  bool operator ==(Object other) => identical(this, other) || other is FormStatusVisual && _status == other._status;

  @override
  int get hashCode => _status.hashCode;
}

extension FormStatusEnumExtension on FormStatusEnum {
  static FormStatusEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return FormStatusEnum.active;
      case 'editing':
        return FormStatusEnum.editing;
      case 'inactive':
        return FormStatusEnum.inactive;
      default:
        return FormStatusEnum.inactive;
    }
  }

  static FormStatusEnum fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'ativo':
        return FormStatusEnum.active;
      case 'em edição':
        return FormStatusEnum.editing;
      case 'inativo':
        return FormStatusEnum.inactive;
      default:
        return FormStatusEnum.inactive;
    }
  }

  String get label => switch (this) {
    FormStatusEnum.active => 'Ativo',
    FormStatusEnum.editing => 'Em edição',
    FormStatusEnum.inactive => 'Inativo',
  };

  IconData get icon => switch (this) {
    FormStatusEnum.active => Symbols.rocket_launch,
    FormStatusEnum.editing => Symbols.edit_document,
    FormStatusEnum.inactive => Symbols.block,
  };

  Color get color => switch (this) {
    FormStatusEnum.inactive => Colors.slate[600],
    FormStatusEnum.editing => Colors.orange,
    FormStatusEnum.active => Colors.blue,
  };
}

class FormStatus extends StatelessWidget {
  final FormStatusEnum status;
  const FormStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final visual = FormStatusVisual(status);

    return StatusWidget<FormStatusVisual>(status: visual, icon: status.icon);
  }
}
