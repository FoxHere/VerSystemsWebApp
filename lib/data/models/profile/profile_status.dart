import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/ui/shared/components/status_widget/status_widget.dart';

enum ProfileStatusEnum { active, inactive }

class ProfileStatusVisual implements StatusVisual {
  ProfileStatusVisual(this._status);

  final ProfileStatusEnum _status;

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
  bool operator ==(Object other) => identical(this, other) || other is ProfileStatusVisual && _status == other._status;

  @override
  int get hashCode => _status.hashCode;
}

extension ProfileStatusEnumExtension on ProfileStatusEnum {
  static ProfileStatusEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return ProfileStatusEnum.active;
      case 'inactive':
        return ProfileStatusEnum.inactive;
      default:
        return ProfileStatusEnum.inactive;
    }
  }

  static ProfileStatusEnum fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'ativo':
        return ProfileStatusEnum.active;
      case 'inativo':
        return ProfileStatusEnum.inactive;
      default:
        return ProfileStatusEnum.inactive;
    }
  }

  String get label => switch (this) {
    ProfileStatusEnum.active => 'Ativo',
    ProfileStatusEnum.inactive => 'Inativo',
  };

  IconData get icon => switch (this) {
    ProfileStatusEnum.active => Symbols.rocket_launch,
    ProfileStatusEnum.inactive => Symbols.block,
  };

  Color get color => switch (this) {
    ProfileStatusEnum.inactive => Colors.slate[600],
    ProfileStatusEnum.active => Colors.blue,
  };
}

class ProfileStatusWidget extends StatelessWidget {
  final ProfileStatusEnum status;
  const ProfileStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final visual = ProfileStatusVisual(status);
    return switch (status) {
      ProfileStatusEnum.active => StatusWidget<ProfileStatusVisual>(status: visual, icon: status.icon),
      ProfileStatusEnum.inactive => StatusWidget<ProfileStatusVisual>(status: visual, icon: status.icon),
    };
  }
}
