import 'package:versystems_app/data/models/dashboard/dashboard_p_tasks_model.dart';
import 'package:versystems_app/data/models/dashboard/dashboard_props_model.dart';

class DashboardModel {
  final DashboardPropsModel? formularies;
  final DashboardPropsModel? activities;
  final DashboardPTasksModel? pendentTasks;
  final DashboardPropsModel? members;

  DashboardModel({
    required this.formularies,
    required this.activities,
    required this.pendentTasks,
    required this.members,
  });
  factory DashboardModel.empty() {
    return DashboardModel(
      formularies: DashboardPropsModel.empty(),
      activities: DashboardPropsModel.empty(),
      pendentTasks: DashboardPTasksModel.empty(),
      members: DashboardPropsModel.empty(),
    );
  }
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      formularies: json['formularies'].isNotEmpty
          ? DashboardPropsModel.fromJson(json['formularies'])
          : DashboardPropsModel.empty(),
      activities: json['activities'].isNotEmpty
          ? DashboardPropsModel.fromJson(json['activities'])
          : DashboardPropsModel.empty(),
      pendentTasks: json['pendentTasks'].isNotEmpty
          ? DashboardPTasksModel.fromJson(json['pendentTasks'])
          : DashboardPTasksModel.empty(),
      members: json['members'].isNotEmpty
          ? DashboardPropsModel.fromJson(json['members'])
          : DashboardPropsModel.empty(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'formularies': formularies?.toJson(),
      'activities': activities?.toJson(),
      'tasks': pendentTasks?.toJson(),
      'members': members?.toJson(),
    };
  }
}
