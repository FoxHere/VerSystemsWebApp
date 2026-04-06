import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/data/models/user/user_status.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/data/models/user/user_settings_model.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

class UserModel implements HasModelStatus<UserStatusVisual> {
  @override
  final String id;
  @override
  UserStatusVisual get status => UserStatusVisual(userStatus);

  final UserStatusEnum userStatus;
  final String name;
  final String email; // Email principal para cadastro
  final List<String> emails; // Lista de emails adicionais
  final List<String> cellphones; // Lista de celulares
  final List<String> telephones; // Lista de telefones
  final DepartmentModel department;
  final ProfileModel profile;
  final String company;
  final ImageItemModel? profileImage;

  // Novos campos profissionais
  final String? cpf;
  final String? birthDate;
  final String? role;
  final bool isActive;
  final UserSettingsModel settings;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.userStatus,
    required this.name,
    required this.email,
    this.emails = const [],
    this.cellphones = const [],
    this.telephones = const [],
    required this.department,
    required this.profile,
    required this.company,
    this.profileImage,
    this.cpf,
    this.birthDate,
    this.role,
    this.isActive = true,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];
    final emailsRaw = json['emails'];
    final cellphonesRaw = json['cellphones'];
    final telephonesRaw = json['telephones'];

    return UserModel(
      id: json['id'],
      userStatus: UserStatusEnumExtension.fromString(json['userStatus']),
      name: json['name'],
      email: json['email'] ?? '',
      emails: _parseStringList(emailsRaw),
      cellphones: _parseStringList(cellphonesRaw),
      telephones: _parseStringList(telephonesRaw),
      department: DepartmentModel.fromJson(json['department']),
      profile: ProfileModel.fromJson(json['profile']),
      company: json['company'],
      profileImage: ImageItemModel.fromFirebase(json['profileImage']),
      cpf: json['cpf'],
      birthDate: json['birthDate'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
      settings: UserSettingsModel.fromJson(json['settings']),
      createdAt: createdAtRaw == null
          ? null
          : createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.parse(createdAtRaw.toString()),
      updatedAt: updatedAtRaw == null
          ? null
          : updatedAtRaw is Timestamp
          ? updatedAtRaw.toDate()
          : DateTime.parse(updatedAtRaw.toString()),
    );
  }

  factory UserModel.empty() {
    return UserModel(
      id: '',
      userStatus: UserStatusEnum.active,
      name: '',
      email: '',
      emails: [],
      cellphones: [],
      telephones: [],
      department: DepartmentModel.empty(),
      profile: ProfileModel.empty(),
      profileImage: ImageItemModel.empty(),
      company: '',
      cpf: '',
      birthDate: '',
      role: '',
      isActive: true,
      settings: UserSettingsModel.empty(),
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userStatus': userStatus.name,
    'name': name,
    'email': email,
    'emails': emails,
    'cellphones': cellphones,
    'telephones': telephones,
    'department': department.toJson(),
    'profile': profile.toJson(),
    'company': company,
    'profileImage': profileImage?.toJson(),
    'cpf': cpf,
    'birthDate': birthDate,
    'role': role,
    'isActive': isActive,
    'settings': settings.toJson(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  Map<String, dynamic> toJsonForFirebase() => {
    'id': id,
    'userStatus': userStatus.name,
    'name': name,
    'email': email,
    'emails': emails,
    'cellphones': cellphones,
    'telephones': telephones,
    'department': department.id,
    'profile': profile.id,
    'company': company,
    'profileImage': profileImage?.toJsonForFirebase(),
    'cpf': cpf,
    'birthDate': birthDate,
    'role': role,
    'isActive': isActive,
    'settings': settings.toJsonForFirebase(),
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };

  factory UserModel.fromFirebase({
    required String id,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> departmentData,
    required Map<String, dynamic> profileData,
  }) {
    final createdAtRaw = userData['createdAt'];
    final updatedAtRaw = userData['updatedAt'];
    final emailsRaw = userData['emails'];
    final cellphonesRaw = userData['cellphones'];
    final telephonesRaw = userData['telephones'];

    return UserModel(
      id: id,
      userStatus: UserStatusEnumExtension.fromString(userData['userStatus']),
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      emails: _parseStringList(emailsRaw),
      cellphones: _parseStringList(cellphonesRaw),
      telephones: _parseStringList(telephonesRaw),
      company: userData['company'] ?? '',
      department: DepartmentModel.fromJson(departmentData),
      profile: ProfileModel.fromJson(profileData),
      profileImage: userData['profileImage'].isNotEmpty ? ImageItemModel.fromFirebase(userData['profileImage']) : null,
      cpf: userData['cpf'],
      birthDate: userData['birthDate'],
      role: userData['role'],
      isActive: userData['isActive'] ?? true,
      settings: UserSettingsModel.fromFirebase(userData['settings']),
      createdAt: createdAtRaw == null
          ? null
          : createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.parse(createdAtRaw.toString()),
      updatedAt: updatedAtRaw == null
          ? null
          : updatedAtRaw is Timestamp
          ? updatedAtRaw.toDate()
          : DateTime.parse(updatedAtRaw.toString()),
    );
  }

  UserModel get createdBy => UserModel(
    id: id,
    userStatus: userStatus,
    name: name,
    email: email,
    emails: emails,
    cellphones: cellphones,
    telephones: telephones,
    department: department,
    profile: profile,
    company: company,
    profileImage: profileImage,
    cpf: cpf,
    birthDate: birthDate,
    role: role,
    isActive: isActive,
    settings: settings,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  bool get isAppAdmin => profile.level >= 1000 && profile.name.toLowerCase().contains("administrador");

  UserModel copyWith({
    String? id,
    UserStatusEnum? userStatus,
    String? name,
    String? email,
    List<String>? emails,
    List<String>? cellphones,
    List<String>? telephones,
    DepartmentModel? department,
    ProfileModel? profile,
    String? company,
    ImageItemModel? profileImage,
    String? cpf,
    String? birthDate,
    String? role,
    bool? isActive,
    UserSettingsModel? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userStatus: userStatus ?? this.userStatus,
      name: name ?? this.name,
      email: email ?? this.email,
      emails: emails ?? this.emails,
      cellphones: cellphones ?? this.cellphones,
      telephones: telephones ?? this.telephones,
      department: department ?? this.department,
      profile: profile ?? this.profile,
      company: company ?? this.company,
      profileImage: profileImage ?? this.profileImage,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<String> _parseStringList(dynamic rawList) {
    if (rawList == null || rawList is! Iterable) return [];
    return rawList.map((e) {
      if (e is String) return e;
      if (e is Map) {
        // Some previous data might be stored as maps like {'email': '...'} or {'cellphone': '...'}
        return e.values.firstOrNull?.toString() ?? e.toString();
      }
      return e.toString();
    }).toList();
  }
}
