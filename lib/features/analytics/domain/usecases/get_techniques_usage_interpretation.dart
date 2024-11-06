import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/models/chart_data.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class GetTechniquesUsageInterpretation {
  final RemarkRepository _remarkRepository;

  const GetTechniquesUsageInterpretation(this._remarkRepository);

  Future<Either<Failure, String>> call(List<ChartData> chartData) async {
    return await _remarkRepository.getTechniquesUsageInterpretation(chartData);
  }
}
