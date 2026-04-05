enum AppThemeMode { light, dark, system }

extension AppThemeModeExtension on AppThemeMode {
  static AppThemeMode fromString(String? key) {
    if (key == null) return AppThemeMode.system;
    return AppThemeMode.values.firstWhere(
      (e) => e.name == key,
      orElse: () => AppThemeMode.system,
    );
  }
}

class UserSettingsModel {
  final AppThemeMode themeMode;
  final bool notificationsEnabled;
  final String language;

  UserSettingsModel({
    required this.themeMode,
    required this.notificationsEnabled,
    required this.language,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserSettingsModel.empty();
    return UserSettingsModel(
      themeMode: AppThemeModeExtension.fromString(json['themeMode']),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      language: json['language'] ?? 'pt_BR',
    );
  }

  factory UserSettingsModel.fromFirebase(Map<String, dynamic>? json) {
    if (json == null) return UserSettingsModel.empty();
    return UserSettingsModel.fromJson(json);
  }

  factory UserSettingsModel.empty() {
    return UserSettingsModel(
      themeMode: AppThemeMode.system,
      notificationsEnabled: true,
      language: 'pt_BR',
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'notificationsEnabled': notificationsEnabled,
    'language': language,
  };

  Map<String, dynamic> toJsonForFirebase() => toJson();

  UserSettingsModel copyWith({
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    String? language,
  }) {
    return UserSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }
}
