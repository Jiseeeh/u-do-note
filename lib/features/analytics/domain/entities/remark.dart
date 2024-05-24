import 'package:cloud_firestore/cloud_firestore.dart';

class RemarkEntity {
  final String? id;
  final String? leitnerRemark;
  final int? leitnerScore;
  final Timestamp timestamp;

  RemarkEntity({
    this.id,
    this.leitnerRemark,
    this.leitnerScore,
    required this.timestamp,
  });
}
