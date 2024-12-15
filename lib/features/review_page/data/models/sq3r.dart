import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/data/models/question.dart';
import 'package:u_do_note/core/shared/data/models/quiz.dart';

class Sq3rModel extends QuizModel {
  final String? id;
  final String sessionName;
  final String notebookId;
  final String contentUsed;
  final String topEditorJsonContent;
  final String bottomEditorJsonContent;
  final Timestamp createdAt;
  static const coverImagePath = "assets/images/sq3r.png";
  static const name = "SQ3R";

  const Sq3rModel(
      {super.questions,
      super.selectedAnswersIndex,
      super.score,
      super.remark,
      this.id,
      required this.contentUsed,
      required this.sessionName,
      required this.notebookId,
      required this.topEditorJsonContent,
      required this.bottomEditorJsonContent,
      required this.createdAt});

  /// Converts from model to firestore
  Map<String, dynamic> toFirestore() {
    return {
      "content_used": contentUsed,
      "session_name": sessionName,
      "notebook_id": notebookId,
      "top_editor_json_content": topEditorJsonContent,
      "bottom_editor_json_content": bottomEditorJsonContent,
      "created_at": createdAt,
      'questions':
          questions?.map((question) => question.toJson()).toList() ?? [],
      'selected_answers_index': selectedAnswersIndex ?? [],
      'score': score,
      'remark': remark,
      'review_method': name,
    };
  }

  /// Converts from firestore to model
  factory Sq3rModel.fromFirestore(String id, Map<String, dynamic> data) {
    return Sq3rModel(
        id: id,
        contentUsed: data['content_used'],
        sessionName: data['session_name'],
        notebookId: data['notebook_id'],
        topEditorJsonContent: data['top_editor_json_content'],
        bottomEditorJsonContent: data['bottom_editor_json_content'],
        createdAt: data['created_at'],
        questions: (data['questions'] as List)
            .map((question) => QuestionModel.fromJson(question))
            .toList(),
        selectedAnswersIndex: List<int>.from(data['selected_answers_index']),
        score: data['score'],
        remark: data['remark']);
  }

  /// Copy with new values
  Sq3rModel copyWith(
      {String? id,
      String? contentUsed,
      String? sessionName,
      String? notebookId,
      String? topEditorJsonContent,
      String? bottomEditorJsonContent,
      Timestamp? createdAt,
      List<QuestionModel>? questions,
      List<int>? selectedAnswersIndex,
      int? score,
      String? remark}) {
    return Sq3rModel(
        id: id ?? this.id,
        contentUsed: contentUsed ?? this.contentUsed,
        sessionName: sessionName ?? this.sessionName,
        notebookId: notebookId ?? this.notebookId,
        topEditorJsonContent: topEditorJsonContent ?? this.topEditorJsonContent,
        bottomEditorJsonContent:
            bottomEditorJsonContent ?? this.bottomEditorJsonContent,
        createdAt: createdAt ?? this.createdAt,
        questions: questions ?? this.questions,
        selectedAnswersIndex: selectedAnswersIndex ?? this.selectedAnswersIndex,
        score: score ?? this.score,
        remark: remark ?? this.remark);
  }
}
