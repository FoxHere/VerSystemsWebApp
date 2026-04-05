import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/components/status_widget/status_widget.dart';

enum UserStatusEnum { active, inactive }

class UserStatusVisual implements StatusVisual {
  UserStatusVisual(this._status);

  final UserStatusEnum _status;

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
  bool operator ==(Object other) => identical(this, other) || other is UserStatusVisual && _status == other._status;

  @override
  int get hashCode => _status.hashCode;
}

extension UserStatusEnumExtension on UserStatusEnum {
  static UserStatusEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return UserStatusEnum.active;
      case 'inactive':
        return UserStatusEnum.inactive;
      default:
        return UserStatusEnum.inactive;
    }
  }

  static UserStatusEnum fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'ativo':
        return UserStatusEnum.active;
      case 'inativo':
        return UserStatusEnum.inactive;
      default:
        return UserStatusEnum.inactive;
    }
  }

  String get label => switch (this) {
    UserStatusEnum.active => 'Ativo',
    UserStatusEnum.inactive => 'Inativo',
  };

  IconData get icon => switch (this) {
    UserStatusEnum.active => Symbols.rocket_launch,
    UserStatusEnum.inactive => Symbols.block,
  };

  Color get color => switch (this) {
    UserStatusEnum.inactive => Colors.slate[600],
    UserStatusEnum.active => Colors.blue,
  };
}

class UserStatusWidget extends StatelessWidget {
  final UserStatusEnum status;
  const UserStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final visual = UserStatusVisual(status);
    return switch (status) {
      UserStatusEnum.active => StatusWidget<UserStatusVisual>(status: visual, icon: status.icon),
      UserStatusEnum.inactive => StatusWidget<UserStatusVisual>(status: visual, icon: status.icon),
    };
  }
}
