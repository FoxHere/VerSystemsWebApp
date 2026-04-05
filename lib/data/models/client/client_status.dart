import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/components/status_widget/status_widget.dart';

enum ClientStatusEnum { active, inactive }

class ClientStatusVisual implements StatusVisual {
  ClientStatusVisual(this._status);

  final ClientStatusEnum _status;

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
  bool operator ==(Object other) => identical(this, other) || other is ClientStatusVisual && _status == other._status;

  @override
  int get hashCode => _status.hashCode;
}

extension ClientStatusEnumExtension on ClientStatusEnum {
  static ClientStatusEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return ClientStatusEnum.active;
      case 'inactive':
        return ClientStatusEnum.inactive;
      default:
        return ClientStatusEnum.inactive;
    }
  }

  static ClientStatusEnum fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'ativo':
        return ClientStatusEnum.active;
      case 'inativo':
        return ClientStatusEnum.inactive;
      default:
        return ClientStatusEnum.inactive;
    }
  }

  String get label => switch (this) {
    ClientStatusEnum.active => 'Ativo',
    ClientStatusEnum.inactive => 'Inativo',
  };

  IconData get icon => switch (this) {
    ClientStatusEnum.active => Symbols.rocket_launch,
    ClientStatusEnum.inactive => Symbols.block,
  };

  Color get color => switch (this) {
    ClientStatusEnum.inactive => Colors.slate[600],
    ClientStatusEnum.active => Colors.blue,
  };
}

class ClientStatusWidget extends StatelessWidget {
  final ClientStatusEnum status;
  const ClientStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final visual = ClientStatusVisual(status);
    return switch (status) {
      ClientStatusEnum.active => StatusWidget<ClientStatusVisual>(status: visual, icon: status.icon),
      ClientStatusEnum.inactive => StatusWidget<ClientStatusVisual>(status: visual, icon: status.icon),
    };
  }
}
