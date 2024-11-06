import 'package:intl/intl.dart';

class ScoresData {
  final DateTime createdAt;
  final int score;

  const ScoresData(this.createdAt, this.score);

  @override
  String toString() {
    return "Date: ${DateFormat('MMM d, y').format(createdAt)}\n score: $score";
  }
}
