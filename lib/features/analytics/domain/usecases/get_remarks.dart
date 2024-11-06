import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class GetRemarks {
  final RemarkRepository _remarkRepository;

  GetRemarks(this._remarkRepository);

  Future<Either<Failure, Map<String, List<TempRemark>>>> call() async {
    return await _remarkRepository.getRemarks();
  }
}
