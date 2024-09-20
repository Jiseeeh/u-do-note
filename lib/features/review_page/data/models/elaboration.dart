import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/data/models/quiz.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';

class ElaborationModel extends QuizModel {
  final String? id;
  final String content;
  final String sessionName;
  final Timestamp createdAt;
  static const coverImagePath = "assets/images/elaboration.webp";
  static const name = "Elaboration";

  const ElaborationModel({
    super.questions,
    super.selectedAnswersIndex,
    super.score,
    super.remark,
    this.id,
    required this.content,
    required this.sessionName,
    required this.createdAt,
  });

  /// Converts from firestore to model
  factory ElaborationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ElaborationModel(
      id: id,
      content: data['content'],
      sessionName: data['session_name'],
      createdAt: data['created_at'],
      questions: (data['questions'] as List)
          .map((question) => QuestionModel.fromJson(question))
          .toList(),
      selectedAnswersIndex: List<int>.from(data['selected_answers_index']),
      score: data['score'],
      remark: data['remark'],
    );
  }

  /// Converts from model to firestore
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'session_name': sessionName,
      'created_at': createdAt,
      'questions':
          questions?.map((question) => question.toJson()).toList() ?? [],
      'selected_answers_index': selectedAnswersIndex ?? [],
      'score': score,
      'remark': remark,
      'review_method': name,
    };
  }

  /// Copy with new values
  ElaborationModel copyWith({
    String? id,
    String? content,
    String? sessionName,
    Timestamp? createdAt,
    List<QuestionModel>? questions,
    List<int>? selectedAnswersIndex,
    int? score,
    String? remark,
  }) {
    return ElaborationModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sessionName: sessionName ?? this.sessionName,
      createdAt: createdAt ?? this.createdAt,
      questions: questions ?? this.questions,
      selectedAnswersIndex: selectedAnswersIndex ?? this.selectedAnswersIndex,
      score: score ?? this.score,
      remark: remark ?? this.remark,
    );
  }
}
