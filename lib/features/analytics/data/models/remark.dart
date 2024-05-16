import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';

import 'package:u_do_note/features/review_page/data/models/leitner.dart';

class RemarkModel {
  final String? id;
  final String? leitnerRemark;
  final int? leitnerScore;
  final String? feynmanRemark;
  final int? feynmanScore;
  final Timestamp? leitnerTimestamp;
  final Timestamp? feynmanTimestamp;

  RemarkModel({
    this.id,
    this.leitnerRemark,
    this.leitnerScore,
    this.feynmanRemark,
    this.feynmanScore,
    this.leitnerTimestamp,
    this.feynmanTimestamp,
  });

  /// Converts from firestore to model
  factory RemarkModel.fromFirestore(
      {required String id,
      required String reviewMethod,
      required Map<String, dynamic> data}) {
    switch (reviewMethod) {
      case LeitnerSystemModel.name:
        return RemarkModel(
          id: id,
          leitnerRemark: data['remark'],
          leitnerScore: data['score'],
          leitnerTimestamp: data['created_at'],
        );
      case FeynmanModel.name:
        return RemarkModel(
          id: id,
          feynmanRemark: data['remark'],
          feynmanScore: data['score'],
          feynmanTimestamp: data['created_at'],
        );
      default:
        throw Exception("Unknown review method: $reviewMethod");
    }
  }
}
