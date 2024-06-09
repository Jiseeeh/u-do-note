import 'package:u_do_note/features/review_page/domain/entities/question.dart';

class QuestionModel {
  final String? id;
  final String question;
  final List<String> choices;
  final int correctAnswerIndex;

  QuestionModel({
    this.id,
    required this.question,
    required this.choices,
    required this.correctAnswerIndex,
  });

  /// Converts from firestore data to model
  factory QuestionModel.fromFirestore(String id, Map<String, dynamic> data) {
    return QuestionModel(
      id: id,
      question: data['question'],
      choices: List<String>.from(data['choices']),
      correctAnswerIndex: data['correctAnswerIndex'],
    );
  }

  /// Converts from json to model
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final String id =
        json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    return QuestionModel(
      id: id,
      question: json['question'],
      choices: List<String>.from(json['choices']),
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }

  /// Converts from model to firestore data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'choices': choices,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  /// Converts from model to entity
  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      question: question,
      choices: choices,
      correctAnswerIndex: correctAnswerIndex,
    );
  }

  /// Converts from entity to model
  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      id: entity.id,
      question: entity.question,
      choices: entity.choices,
      correctAnswerIndex: entity.correctAnswerIndex,
    );
  }
}
