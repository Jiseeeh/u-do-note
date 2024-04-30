import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class FeynmanEntity {
  final String? id;
  final String sessionName;
  final String contentFromPagesUsed;
  final List<types.Message> messages;
  final List<String> recentRobotMessages;
  final List<String> recentUserMessages;
  static const name = "Feynman Technique";

  const FeynmanEntity({
    this.id,
    required this.sessionName,
    required this.contentFromPagesUsed,
    required this.messages,
    required this.recentRobotMessages,
    required this.recentUserMessages,
  });
}
