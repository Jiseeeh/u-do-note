import 'package:u_do_note/features/analytics/domain/entities/leitner_remark.dart';

class LeitnerSystemRemarkModel {
  final String? id;
  final List<String> remarks;
  final List<int> scores;

  LeitnerSystemRemarkModel({
    this.id,
    required this.remarks,
    required this.scores,
  });

  /// Converts from firestore to model
  factory LeitnerSystemRemarkModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return LeitnerSystemRemarkModel(
      id: id,
      remarks: List<String>.from(data['remarks']),
      scores: List<int>.from(data['scores']),
    );
  }

  /// Converts from model to json
  Map<String, dynamic> toJson() {
    return {
      'remarks': remarks,
      'scores': scores,
    };
  }

  /// Converts from model to entity
  LeitnerSystemRemarkEntity toEntity() {
    return LeitnerSystemRemarkEntity(
      id: id,
      remarks: remarks,
      scores: scores,
    );
  }

  /// Converts from entity to model
  factory LeitnerSystemRemarkModel.fromEntity(
      LeitnerSystemRemarkEntity entity) {
    return LeitnerSystemRemarkModel(
      id: entity.id,
      remarks: entity.remarks,
      scores: entity.scores,
    );
  }
}
