import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:u_do_note/features/analytics/data/models/remark_data.dart';

class RemarkModel {
  final String? id;
  final RemarkDataModel? leitnerRemark;
  final RemarkDataModel? feynmanRemark;
  final RemarkDataModel? pomodoroRemark;

  RemarkModel({
    this.id,
    this.leitnerRemark,
    this.feynmanRemark,
    this.pomodoroRemark,
  });

  /// Converts to a json object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leitnerRemark': leitnerRemark?.toJson(),
      'feynmanRemark': feynmanRemark?.toJson(),
      'pomodoroRemark': pomodoroRemark?.toJson(),
    };
  }

  /// Converts from json to a RemarkModel
  factory RemarkModel.fromJson(Map<String, dynamic> json) {
    return RemarkModel(
      id: json['id'],
      leitnerRemark: json['leitnerRemark'] != null
          ? RemarkDataModel.fromJson(json['leitnerRemark'])
          : null,
      feynmanRemark: json['feynmanRemark'] != null
          ? RemarkDataModel.fromJson(json['feynmanRemark'])
          : null,
      pomodoroRemark: json['pomodoroRemark'] != null
          ? RemarkDataModel.fromJson(json['pomodoroRemark'])
          : null,
    );
  }

  @override
  String toString() {
    return """
           ${leitnerRemark != null ? 'Leitner Remark at ${leitnerRemark!.timestamp.toDate().toIso8601String()}: is ${leitnerRemark!.remark} with a score of ${leitnerRemark!.score}' : ''}
           ${feynmanRemark != null ? 'Feynman Remark at ${feynmanRemark!.timestamp.toDate().toIso8601String()}: is ${feynmanRemark!.remark} with a score of ${feynmanRemark!.score}' : ''}
           ${pomodoroRemark != null ? 'Pomodoro Remark at ${pomodoroRemark!.timestamp.toDate().toIso8601String()}: is ${pomodoroRemark!.remark} with a score of ${pomodoroRemark!.score}' : ''}
           """;
  }
}

class TempRemark {
  final String? id;
  final String notebookName;
  final String notebookId;
  final Timestamp createdAt;
  final String reviewMethod;
  final int score;

  const TempRemark({
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
