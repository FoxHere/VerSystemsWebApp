import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/data/models/company/company_status.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/data/models/company/company_address_model.dart';

class CompanyModel implements HasModelStatus<CompanyStatusVisual> {
  @override
  final String id;
  @override
  CompanyStatusVisual get status => CompanyStatusVisual(companyStatus);

  // Basic info
  final String name;
  final CompanyStatusEnum companyStatus;
  final String? tradeName;
  final String cnpj;
  final String? stateRegistration;
  final String? municipalRegistration;

  // Contact
  final String? email;
  final String? phone;
  final String? website;

  // Address
  final List<CompanyAddressModel> addresses;

  // Additional options
  final bool isActive;
  final String? notes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.companyStatus,
    this.tradeName,
    required this.cnpj,
    this.stateRegistration,
    this.municipalRegistration,
    this.email,
    this.phone,
    this.website,
    required this.addresses,
    this.isActive = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];

    // Migration logic for old string `address`
    List<CompanyAddressModel> addressesList = [];
    if (json['addresses'] != null) {
      addressesList = (json['addresses'] as List).map((addr) => CompanyAddressModel.fromJson(addr as Map<String, dynamic>)).toList();
    } else if (json['address'] != null && json['address'].toString().isNotEmpty) {
      addressesList.add(
        CompanyAddressModel(street: json['address'] ?? '', number: '', complement: '', neighborhood: '', city: '', state: '', zipCode: ''),
      );
    }

    if (addressesList.isEmpty) {
      addressesList.add(CompanyAddressModel.empty());
    }

    return CompanyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      tradeName: json['tradeName'],
      companyStatus: CompanyStatusEnumExtension.fromString(json['companyStatus']),
      cnpj: json['cnpj'] ?? '',
      stateRegistration: json['stateRegistration'],
      municipalRegistration: json['municipalRegistration'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      addresses: addressesList,
      isActive: json['isActive'] ?? true, // default backward compatible
      notes: json['notes'],
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : (createdAtRaw != null ? DateTime.parse(createdAtRaw) : null),
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : (updatedAtRaw != null ? DateTime.parse(updatedAtRaw) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tradeName': tradeName,
      'companyStatus': companyStatus.name,
      'cnpj': cnpj,
      'stateRegistration': stateRegistration,
      'municipalRegistration': municipalRegistration,
      'email': email,
      'phone': phone,
      'website': website,
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForFirebase() {
    return {
      'id': id,
      'name': name,
      'tradeName': tradeName,
      'companyStatus': companyStatus.name,
      'cnpj': cnpj,
      'stateRegistration': stateRegistration,
      'municipalRegistration': municipalRegistration,
      'email': email,
      'phone': phone,
      'website': website,
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory CompanyModel.empty() => CompanyModel(
    id: '',
    name: '',
    tradeName: '',
    companyStatus: CompanyStatusEnum.active,
    cnpj: '',
    stateRegistration: '',
    municipalRegistration: '',
    email: '',
    phone: '',
    website: '',
    addresses: [],
    isActive: true,
    notes: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  CompanyModel copyWith({
    String? id,
    String? name,
    String? tradeName,
    CompanyStatusEnum? companyStatus,
    String? cnpj,
    String? stateRegistration,
    String? municipalRegistration,
    String? email,
    String? phone,
    String? website,
    List<CompanyAddressModel>? addresses,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tradeName: tradeName ?? this.tradeName,
      companyStatus: companyStatus ?? this.companyStatus,
      cnpj: cnpj ?? this.cnpj,
      stateRegistration: stateRegistration ?? this.stateRegistration,
      municipalRegistration: municipalRegistration ?? this.municipalRegistration,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      addresses: addresses ?? this.addresses,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
