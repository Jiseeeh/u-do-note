import 'package:u_do_note/features/analytics/data/models/remark_data.dart';

class RemarkModel {
  final String? id;
  final RemarkDataModel? leitnerRemark;
  final RemarkDataModel? feynmanRemark;

  RemarkModel({
    this.id,
    this.leitnerRemark,
    this.feynmanRemark,
  });

  /// Converts to a json object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leitnerRemark': leitnerRemark?.toJson(),
      'feynmanRemark': feynmanRemark?.toJson(),
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
    );
  }

  @override
  String toString() {
    return """
           ${leitnerRemark != null ? 'Leitner Remark at ${leitnerRemark!.timestamp.toDate().toIso8601String()}: is ${leitnerRemark!.remark} with a score of ${leitnerRemark!.score}' : ''}
           ${feynmanRemark != null ? 'Feynman Remark at ${feynmanRemark!.timestamp.toDate().toIso8601String()}: is ${feynmanRemark!.remark} with a score of ${feynmanRemark!.score}' : ''}
           """;
  }
}
