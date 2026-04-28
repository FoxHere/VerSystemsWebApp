/*
  Esse Model é o resposável pela criação da tela de atividades 
  que será usada para armazenar no firestore

 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/models/user/user_model.dart';

class ActivityModel implements HasModelStatus<ActivityStatusVisual> {
  ActivityModel({
    required this.id,
    required this.activityStatus,
    required this.name,
    this.instructions,
    this.formulary,
    required this.startDateTime,
    required this.endDateTime,
    this.responsible,
    this.client,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String id;

  /// Status da atividade (enum). Para exibição na tabela padrão usa-se o getter [status] (StatusVisual).
  ActivityStatusEnum activityStatus;
  @override
  ActivityStatusVisual get status => ActivityStatusVisual(activityStatus);
  ActivityStatusVisual get taskStatus => ActivityStatusVisual(activityStatus, isTask: true);
  String name;
  String? instructions;
  FormularyModel? formulary;
  DateTime startDateTime;
  DateTime endDateTime;
  UserModel? responsible;
  ClientModel? client;
  DateTime? createdAt;
  DateTime? updatedAt;
  // Ususário será armazenado como objeto na coleção de atividades

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];
    return ActivityModel(
      id: json['id'],
      activityStatus: ActivityStatusEnumExtension.fromString(json['status']),
      name: json['name'],
      instructions: json['instructions'],
      formulary: FormularyModel.fromJson(json['formulary']),
      startDateTime: json['startDateTime'] is Timestamp
          ? json['startDateTime'].toDate()
          : DateTime.parse(json['startDateTime']),
      endDateTime: json['endDateTime'] is Timestamp
          ? json['endDateTime'].toDate()
          : DateTime.parse(json['endDateTime']),
      responsible: UserModel.fromJson(json['responsible']),
      client: json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.parse(createdAtRaw),
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : DateTime.parse(updatedAtRaw),
    );
  }

  factory ActivityModel.empty() => ActivityModel(
    id: '',
    activityStatus: ActivityStatusEnum.active,
    name: '',
    instructions: '',
    formulary: null,
    startDateTime: DateTime.now(),
    endDateTime: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': activityStatus.name,
      'name': name,
      'instructions': instructions,
      'formulary': formulary?.toJson(),
      'responsible': responsible?.toJson(),
      'client': client?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForFirebase() {
    return {
      'id': id,
      'status': activityStatus.name,
      'name': name,
      'instructions': instructions,
      'formulary': formulary?.toJsonForFirebase(),
      'responsible': responsible?.toJsonForFirebase(),
      'client': client?.toJsonForFirebase(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
    };
  }

  ActivityModel copyWith({
    String? id,
    ActivityStatusEnum? activityStatus,
    String? name,
    String? instructions,
    FormularyModel? formulary,
    DateTime? startDateTime,
    DateTime? endDateTime,
    UserModel? responsible,
    ClientModel? client,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      activityStatus: activityStatus ?? this.activityStatus,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      formulary: formulary ?? this.formulary,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      responsible: responsible ?? this.responsible,
      client: client ?? this.client,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
