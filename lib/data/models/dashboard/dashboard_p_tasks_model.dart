import 'package:versystems_app/data/models/dashboard/dashboard_props_model.dart';

class DashboardPTasksModel {
  final int profile;
  final List<DashboardPTasksModelUser?> users;

  DashboardPTasksModel({
    required this.profile,
    required this.users,
  });
  factory DashboardPTasksModel.empty() {
    return DashboardPTasksModel(
      profile: 0,
      users: [],
    );
  }
  factory DashboardPTasksModel.fromJson(Map<String, dynamic> json) {
    final userMap = (json['users'] ?? {}) as Map<String, dynamic>;
    final userList = userMap.entries.map(
      (e) {
        return DashboardPTasksModelUser(
          user: e.key,
          props: DashboardPropsModel.fromJson(e.value ?? {}),
        );
      },
    ).toList();

    return DashboardPTasksModel(
      profile: json['profile'] ?? 0,
      users: userList,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'profile': profile,
      'users': users,
    };
  }
}

class DashboardPTasksModelUser {
  final String user;
  final DashboardPropsModel props;

  DashboardPTasksModelUser({
    required this.user,
    required this.props,
  });
  factory DashboardPTasksModelUser.empty() {
    return DashboardPTasksModelUser(
      user: '',
      props: DashboardPropsModel.empty(),
    );
  }
  factory DashboardPTasksModelUser.fromJson(String key, Map<String, dynamic> json) {
    return DashboardPTasksModelUser(
      user: key,
      props: DashboardPropsModel.fromJson(json),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      user: props.toJson(),
    };
  }
}
