import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/data/models/profile/profile_status.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';

class ProfileModel implements HasModelStatus<ProfileStatusVisual> {
  @override
  final String id;
  @override
  ProfileStatusVisual get status => ProfileStatusVisual(profileStatus);

  final ProfileStatusEnum profileStatus;
  final String name;
  final String description;
  final int level;
  final List<String> allowedMenus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    required this.profileStatus,
    required this.name,
    required this.description,
    required this.level,
    this.allowedMenus = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];
    final allowedMenusRaw = json['allowedMenus'];

    return ProfileModel(
      id: json['id'] ?? '',
      profileStatus: ProfileStatusEnumExtension.fromString(json['profileStatus']),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 0,
      allowedMenus: allowedMenusRaw != null ? List<String>.from(allowedMenusRaw) : [],
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.parse(createdAtRaw),
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : DateTime.parse(updatedAtRaw),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileStatus': profileStatus.name,
      'name': name,
      'description': description,
      'level': level,
      'allowedMenus': allowedMenus,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForFirebase() {
    return {
      'id': id,
      'profileStatus': profileStatus.name,
      'name': name,
      'description': description,
      'level': level,
      'allowedMenus': allowedMenus,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ProfileModel.empty() {
    return ProfileModel(
      id: '',
      profileStatus: ProfileStatusEnum.active,
      name: '',
      description: '',
      level: 0,
      allowedMenus: [],
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  ProfileModel copyWith({
    String? id,
    ProfileStatusEnum? profileStatus,
    String? name,
    String? description,
    int? level,
    List<String>? allowedMenus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      profileStatus: profileStatus ?? this.profileStatus,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      allowedMenus: allowedMenus ?? this.allowedMenus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
