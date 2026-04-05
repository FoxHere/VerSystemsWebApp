import 'package:uuid/uuid.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

class QuestionModel {
  String id;
  String question;
  bool questionRequired;
  String questionType;
  String? questionOptions;
  String? questionInstructions;
  Object? response;
  List<ImageItemModel>? imagesResponse;
  ImageItemModel? signatureResponse;

  QuestionModel({
    required this.id,
    required this.question,
    required this.questionType,
    required this.questionRequired,
    this.questionOptions,
    this.questionInstructions,
    this.response,
    this.imagesResponse,
    this.signatureResponse,
  });

  factory QuestionModel.copy(QuestionModel original) {
    return QuestionModel(
      id: original.id, // mantém o mesmo id (ou gere outro se for “duplicar”)
      question: original.question,
      questionType: original.questionType,
      questionRequired: original.questionRequired,
      questionOptions: original.questionOptions,
      questionInstructions: original.questionInstructions,
      response: original.response,
      imagesResponse: original.imagesResponse,
      signatureResponse: original.signatureResponse,
    );
  }

  factory QuestionModel.empty() => QuestionModel(
    id: const Uuid().v4(),
    question: "Pergunta de texto",
    questionType: "simpleTextInput",
    questionRequired: false,
    questionOptions: "", //"Opção 1;\nOpção 2;\nOpção 3;",
    questionInstructions: "",
  );

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim();
    return QuestionModel(
      id: (id == null || id.isEmpty) ? const Uuid().v4() : id,
      question: json['question'],
      questionType: json['questionType'],
      questionRequired: json['questionRequired'],
      questionOptions: json['questionOptions'],
      questionInstructions: json['questionInstructions'],
      response: json['response'] is String ? json['response'] : json['response'] ?? '',
      imagesResponse: json['imagesResponse'] is List<dynamic>
          ? (json['imagesResponse'] as List<dynamic>).map((e) => ImageItemModel.fromJson(e)).toList()
          : [],
      signatureResponse: json['signatureResponse'] != null ? ImageItemModel.fromJson(json['signatureResponse']) : null,
    );
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    bool? questionRequired,
    String? questionType,
    String? questionOptions,
    String? questionInstructions,
    String? response,
    List<ImageItemModel>? imagesResponse,
    ImageItemModel? signatureResponse,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      questionRequired: questionRequired ?? this.questionRequired,
      questionType: questionType ?? this.questionType,
      questionOptions: questionOptions ?? this.questionOptions,
      questionInstructions: questionInstructions ?? this.questionInstructions,
      response: response ?? this.response,
      imagesResponse: imagesResponse ?? this.imagesResponse,
      signatureResponse: signatureResponse ?? this.signatureResponse,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      "id": id,
      "question": question,
      "questionType": questionType,
      "questionRequired": questionRequired,
      "questionOptions": questionOptions,
      "questionInstructions": questionInstructions,
      "response": response,
      "imagesResponse": imagesResponse?.map((img) => img.toJson()).toList(),
      "signatureResponse": signatureResponse?.toJson(),
    };

    return data;
  }
}
