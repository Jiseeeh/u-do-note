import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/data/models/quiz.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';

class ElaborationModel extends QuizModel {
  final String? id;
  final String sessionName;
  final Timestamp createdAt;
  static const name = "Elaboration";

  const ElaborationModel({
    super.questions,
    super.selectedAnswersIndex,
    super.score,
    super.remark,
    this.id,
    required this.sessionName,
    required this.createdAt,
  });

  /// Converts from firestore to model
  factory ElaborationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ElaborationModel(
      id: id,
      sessionName: data['sessionName'],
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
      'sessionName': sessionName,
      'created_at': createdAt,
      'questions':
          questions?.map((question) => question.toJson()).toList() ?? [],
      'selected_answers_index': selectedAnswersIndex ?? [],
      'score': score ?? 0,
      'remark': remark ?? "",
      'review_method': name,
    };
  }
}
