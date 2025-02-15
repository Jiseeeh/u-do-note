import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class GetAnalysis {
  final RemarkRepository _remarkRepository;

  GetAnalysis(this._remarkRepository);

  Future<Either<Failure, String>> call(
      Map<String, List<RemarkModel>> remarks) async {
    return await _remarkRepository.getAnalysis(remarks);
  }
}
