import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreModel {
  final String? id;
  final Timestamp date;
  final int score;

  ScoreModel({
    this.id,
    required this.date,
    required this.score,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> data) {
    return ScoreModel(
        id: data['id'],
        date: Timestamp.fromMillisecondsSinceEpoch(data['date']),
        score: data['score']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'score': score,
    };
  }
}
