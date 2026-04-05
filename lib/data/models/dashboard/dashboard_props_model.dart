class DashboardPropsModel {
  final int profile;
  final int total;
  final int totalThisMonth;

  DashboardPropsModel({
    required this.profile,
    required this.total,
    required this.totalThisMonth,
  });
  factory DashboardPropsModel.empty() {
    return DashboardPropsModel(
      profile: 0,
      total: 0,
      totalThisMonth: 0,
    );
  }
  factory DashboardPropsModel.fromJson(Map<String, dynamic> json) {
    return DashboardPropsModel(
      profile: json['profile'] ?? 0,
      total: json['total'] ?? 0,
      totalThisMonth: json['total_this_month'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'profile': profile,
      'total': total,
      'total_this_month': totalThisMonth,
    };
  }
}
