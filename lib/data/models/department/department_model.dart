import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/data/models/department/department_status.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';

class DepartmentModel implements HasModelStatus<DepartmentStatusVisual> {
  @override
  final String id;
  @override
  DepartmentStatusVisual get status => DepartmentStatusVisual(departmentStatus);

  final DepartmentStatusEnum departmentStatus;
  final String name;
  final String description;
  final String? managerName;
  final String? contactEmail;
  final String? contactPhone;
  final String? location;
  final bool isActive;
  final String? notes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  DepartmentModel({
    required this.id,
    required this.departmentStatus,
    required this.name,
    required this.description,
    this.managerName,
    this.contactEmail,
    this.contactPhone,
    this.location,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];

    return DepartmentModel(
      id: json['id'] ?? '',
      departmentStatus: DepartmentStatusEnumExtension.fromString(json['departmentStatus']),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      managerName: json['managerName'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      location: json['location'],
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : (createdAtRaw != null ? DateTime.parse(createdAtRaw) : null),
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : (updatedAtRaw != null ? DateTime.parse(updatedAtRaw) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentStatus': departmentStatus.name,
      'name': name,
      'description': description,
      'managerName': managerName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'location': location,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForFirebase() {
    return {
      'id': id,
      'departmentStatus': departmentStatus.name,
      'name': name,
      'description': description,
      'managerName': managerName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'location': location,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory DepartmentModel.empty() => DepartmentModel(
    id: '',
    departmentStatus: DepartmentStatusEnum.active,
    name: '',
    description: '',
    managerName: '',
    contactEmail: '',
    contactPhone: '',
    location: '',
    isActive: true,
    notes: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  DepartmentModel copyWith({
    String? id,
    DepartmentStatusEnum? departmentStatus,
    String? name,
    String? description,
    String? managerName,
    String? contactEmail,
    String? contactPhone,
    String? location,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      departmentStatus: departmentStatus ?? this.departmentStatus,
      name: name ?? this.name,
      description: description ?? this.description,
      managerName: managerName ?? this.managerName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
