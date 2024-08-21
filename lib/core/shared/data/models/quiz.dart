import 'package:u_do_note/core/shared/data/models/question.dart';

class QuizModel {
  final String? remark;
  final int? score;
  final List<QuestionModel>? questions;
  final List<int>? selectedAnswersIndex;

  const QuizModel({
    this.remark,
    this.score,
    this.questions,
    this.selectedAnswersIndex,
  });
}
