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
}
