import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:u_do_note/features/review_page/domain/entities/question.dart';

class FeynmanEntity {
  final String? id;
  final String? remark;
  final int? score;
  final List<QuestionEntity>? questions;
  final List<int>? selectedAnswersIndex;
  final String sessionName;
  final String contentFromPagesUsed;
  final List<types.Message> messages;
  final List<String> recentRobotMessages;
  final List<String> recentUserMessages;
  static const name = "Feynman Technique";

  const FeynmanEntity({
    this.id,
    this.remark,
    this.score,
    this.questions,
    this.selectedAnswersIndex,
    required this.sessionName,
    required this.contentFromPagesUsed,
    required this.messages,
    required this.recentRobotMessages,
    required this.recentUserMessages,
  });
}
