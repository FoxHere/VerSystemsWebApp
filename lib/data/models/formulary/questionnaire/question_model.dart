import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/gps_location_response_model.dart';
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
  GpsLocationResponseModel? locationResponse;

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
    this.locationResponse,
  });

  factory QuestionModel.copy(QuestionModel original) {
    return QuestionModel(
      id: original.id,
      question: original.question,
      questionType: original.questionType,
      questionRequired: original.questionRequired,
      questionOptions: original.questionOptions,
      questionInstructions: original.questionInstructions,
      response: original.response,
      imagesResponse: original.imagesResponse,
      signatureResponse: original.signatureResponse,
      locationResponse: original.locationResponse != null
          ? GpsLocationResponseModel(
              latitude: original.locationResponse!.latitude,
              longitude: original.locationResponse!.longitude,
              accuracy: original.locationResponse!.accuracy,
              capturedAt: original.locationResponse!.capturedAt,
            )
          : null,
    );
  }

  factory QuestionModel.empty() => QuestionModel(
    id: const Uuid().v4(),
    question: "Pergunta de texto",
    questionType: "simpleTextInput",
    questionRequired: false,
    questionOptions: "",
    questionInstructions: "",
  );

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim();

    GpsLocationResponseModel? parsedLocation;
    if (json['locationResponse'] != null && json['locationResponse'] is Map) {
      parsedLocation = GpsLocationResponseModel.fromJson(Map<String, dynamic>.from(json['locationResponse']));
    } else if (json['questionType'] == 'gpsLocationInput' && json['response'] != null) {
      if (json['response'] is Map) {
        parsedLocation = GpsLocationResponseModel.fromJson(Map<String, dynamic>.from(json['response']));
      } else if (json['response'] is String && (json['response'] as String).isNotEmpty) {
        try {
          final decoded = jsonDecode(json['response'] as String);
          if (decoded is Map<String, dynamic>) {
            parsedLocation = GpsLocationResponseModel.fromJson(decoded);
          }
        } catch (_) {}
      }
    }

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
      locationResponse: parsedLocation,
    );
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    bool? questionRequired,
    String? questionType,
    String? questionOptions,
    String? questionInstructions,
    Object? response,
    List<ImageItemModel>? imagesResponse,
    ImageItemModel? signatureResponse,
    GpsLocationResponseModel? locationResponse,
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
      locationResponse: locationResponse ?? this.locationResponse,
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
      "locationResponse": locationResponse?.toJson(),
    };

    return data;
  }

  Map<String, dynamic> toJsonForFirebase() {
    final Map<String, dynamic> data = <String, dynamic>{
      "id": id,
      "question": question,
      "questionType": questionType,
      "questionRequired": questionRequired,
      "questionOptions": questionOptions,
      "questionInstructions": questionInstructions,
      "response": locationResponse != null ? locationResponse!.toJsonForFirebase() : response,
      "imagesResponse": imagesResponse?.map((img) => img.toJson()).toList(),
      "signatureResponse": signatureResponse?.toJson(),
      "locationResponse": locationResponse?.toJsonForFirebase(),
    };

    return data;
  }
}

