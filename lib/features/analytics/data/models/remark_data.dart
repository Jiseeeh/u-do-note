import 'package:cloud_firestore/cloud_firestore.dart';

class RemarkDataModel {
  final String reviewMethod;
  final String remark;
  final int score;
  final Timestamp timestamp;

  RemarkDataModel({
    required this.reviewMethod,
    required this.remark,
    required this.score,
    required this.timestamp,
  });

  /// Converts to a json object
  Map<String, dynamic> toJson() {
    return {
      'reviewMethod': reviewMethod,
      'remark': remark,
      'score': score,
      'timestamp': timestamp.toDate().toString(),
    };
  }


  /// Converts from json to a RemarkDataModel
  factory RemarkDataModel.fromJson(Map<String, dynamic> json) {
    return RemarkDataModel(
      reviewMethod: json['reviewMethod'],
      remark: json['remark'],
      score: json['score'],
      timestamp: Timestamp.fromDate(DateTime.parse(json['timestamp'])),
    );
  }
}
