import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/data/models/client/client_status.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/data/models/client/client_address_model.dart';

enum ClientType {
  physical, // Pessoa Física
  legal, // Pessoa Jurídica
}

class ClientModel implements HasModelStatus<ClientStatusVisual> {
  @override
  final String id;
  @override
  ClientStatusVisual get status => ClientStatusVisual(clientStatus);

  final ClientStatusEnum clientStatus;
  final String name;
  final String email;
  final String phone;
  final ClientType clientType;
  final String? cpf; // Para pessoa física
  final String? cnpj; // Para pessoa jurídica
  final List<ClientAddressModel> addresses;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientModel({
    required this.id,
    required this.clientStatus,
    required this.name,
    required this.email,
    required this.phone,
    required this.clientType,
    this.cpf,
    this.cnpj,
    required this.addresses,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];
    final clientTypeString = json['clientType'] ?? 'physical';
    final clientType = clientTypeString == 'legal' ? ClientType.legal : ClientType.physical;

    // Migração: se tiver 'address' antigo, converter para lista
    List<ClientAddressModel> addressesList = [];
    if (json['addresses'] != null) {
      addressesList = (json['addresses'] as List).map((addr) => ClientAddressModel.fromJson(addr as Map<String, dynamic>)).toList();
    } else if (json['address'] != null && json['address'].toString().isNotEmpty) {
      // Migração: converter endereço antigo (string) para novo formato
      addressesList.add(
        ClientAddressModel(street: json['address'] ?? '', number: '', complement: '', neighborhood: '', city: '', state: '', zipCode: ''),
      );
    }

    if (addressesList.isEmpty) {
      addressesList.add(ClientAddressModel.empty());
    }

    return ClientModel(
      id: json['id'] ?? '',
      clientStatus: ClientStatusEnumExtension.fromString(json['clientStatus']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      clientType: clientType,
      cpf: json['cpf'],
      cnpj: json['cnpj'],
      addresses: addressesList,
      notes: json['notes'],
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : (createdAtRaw != null ? DateTime.parse(createdAtRaw) : null),
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : (updatedAtRaw != null ? DateTime.parse(updatedAtRaw) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientStatus': clientStatus.name,
      'name': name,
      'email': email,
      'phone': phone,
      'clientType': clientType == ClientType.legal ? 'legal' : 'physical',
      'cpf': cpf,
      'cnpj': cnpj,
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForFirebase() {
    return {
      'id': id,
      'clientStatus': clientStatus.name,
      'name': name,
      'email': email,
      'phone': phone,
      'clientType': clientType == ClientType.legal ? 'legal' : 'physical',
      'cpf': cpf,
      'cnpj': cnpj,
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ClientModel.empty() => ClientModel(
    id: '',
    clientStatus: ClientStatusEnum.active,
    name: '',
    email: '',
    phone: '',
    clientType: ClientType.physical,
    cpf: '',
    cnpj: '',
    addresses: [],
    notes: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  ClientModel copyWith({
    String? id,
    ClientStatusEnum? clientStatus,
    String? name,
    String? email,
    String? phone,
    ClientType? clientType,
    String? cpf,
    String? cnpj,
    List<ClientAddressModel>? addresses,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      clientStatus: clientStatus ?? this.clientStatus,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      clientType: clientType ?? this.clientType,
      cpf: cpf ?? this.cpf,
      cnpj: cnpj ?? this.cnpj,
      addresses: addresses ?? this.addresses,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
