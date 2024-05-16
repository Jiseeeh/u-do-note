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
}
