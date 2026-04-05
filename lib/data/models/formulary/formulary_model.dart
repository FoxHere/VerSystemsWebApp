// ignore_for_file: public_member_api_docs, sort_constructors_first, overridden_fields
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';
import 'package:versystems_app/data/models/formulary/formulary_status_enum.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/section_model.dart';
import 'package:versystems_app/data/models/user/user_model.dart';

// String time example: 2025-09-15T21:55:20.877
class FormularyModel implements HasModelStatus<FormStatusVisual> {
  @override
  String id;
  String title;
  String description;
  FormStatusEnum formStatus;
  @override
  FormStatusVisual get status => FormStatusVisual(formStatus);
  List<SectionModel> sections;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserModel? createdBy;

  FormularyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.formStatus,
    required this.sections,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  int get questionsCount => sections.map((section) => section.questionsCount).reduce((a, b) => a + b);

  factory FormularyModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];
    final createdByRaw = json['createdBy'];

    return FormularyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      formStatus: FormStatusEnumExtension.fromString(json['status']),
      sections: (json['sections'] as List).map((s) => SectionModel.fromJson(s)).toList(),
      createdAt: createdAtRaw == null
          ? null
          : createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.parse(createdAtRaw),
      updatedAt: updatedAtRaw == null
          ? null
          : updatedAtRaw is Timestamp
          ? updatedAtRaw.toDate()
          : DateTime.parse(updatedAtRaw),
      createdBy: createdByRaw != null ? UserModel.fromJson(createdByRaw) : null,
    );
  }

  factory FormularyModel.empty() => FormularyModel(
    id: '',
    title: '',
    description: '',
    formStatus: FormStatusEnum.editing,
    sections: <SectionModel>[
      SectionModel(
        id: const Uuid().v4(),
        sectionTitle: "Informações Gerais",
        questions: List.generate(
          1,
          (_) => QuestionModel(
            id: const Uuid().v4(),
            question: "Nova pergunta",
            questionType: "simpleTextInput",
            questionRequired: false,
            questionOptions: "",
            questionInstructions: "",
          ),
        ),
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: null,
    createdBy: null,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': formStatus.name,
      'sections': sections.map((s) => s.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy?.toJson(),
    };
  }

  Map<String, dynamic> toJsonForFirebase() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': formStatus.name,
      'sections': sections.map((s) => s.toJson()).toList(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'createdBy': createdBy?.toJsonForFirebase(),
    };
  }

  FormularyModel copyWith({
    String? id,
    String? title,
    String? description,
    FormStatusEnum? formStatus,
    List<SectionModel>? sections,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? createdBy,
  }) {
    return FormularyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      formStatus: formStatus ?? this.formStatus,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
