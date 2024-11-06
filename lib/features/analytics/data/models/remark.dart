import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RemarkModel {
  final String? id;
  final String notebookName;
  final String notebookId;
  final Timestamp createdAt;
  final String reviewMethod;
  final int score;

  const RemarkModel({
    this.id,
    required this.notebookName,
    required this.notebookId,
    required this.createdAt,
    required this.reviewMethod,
    required this.score,
  });

  @override
  String toString() {
    return "Notebook name: $notebookName\n score: $score\n method: $reviewMethod\n timestamp: ${DateFormat('MMM d, y').format(createdAt.toDate())}";
  }
}
