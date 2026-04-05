import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';

class SectionModel {
  String id;
  String sectionTitle;
  List<QuestionModel> questions;

  int get questionsCount => questions.length;

  SectionModel({required this.sectionTitle, required this.questions, required this.id});

  SectionModel.copy(SectionModel original)
    : id = original.id,
      sectionTitle = original.sectionTitle,
      questions = List<QuestionModel>.from(original.questions.map((p) => QuestionModel.copy(p)));

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'],
      sectionTitle: json['sectionTitle'],
      questions: (json['questions'] as List).map((p) => QuestionModel.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "sectionTitle": sectionTitle,
    "questions": questions.map((pergunta) => pergunta.toJson()).toList(),
  };
}
