import 'package:cloud_firestore/cloud_firestore.dart';

class RemarkDataModel {
  final String remark;
  final int score;
  final Timestamp timestamp;

  RemarkDataModel({
    required this.remark,
    required this.score,
    required this.timestamp,
  });
}
