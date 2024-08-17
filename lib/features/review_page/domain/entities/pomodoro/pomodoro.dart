import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/domain/entities/question.dart';

class PomodoroEntity {
  final String title;
  final int focusedMinutes;
  final Timestamp createdAt;
  final String? id;
  final String? remark;
  final int? score;
  // ? might be needed if users are allowed to review all quizzes
  final List<QuestionEntity>? questions;
  final List<int>? selectedAnswersIndex;
  static const name = "Pomodoro Technique";

  PomodoroEntity({
    required this.title,
    required this.focusedMinutes,
    required this.createdAt,
    this.id,
    this.remark,
    this.score,
    this.questions,
    this.selectedAnswersIndex,
  });
}
