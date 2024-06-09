import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class GetQuizzesToTake {
  final RemarkRepository _remarkRepository;

  GetQuizzesToTake(this._remarkRepository);

  Future<Either<Failure, int>> call() async {
    return await _remarkRepository.getQuizzesToTake();
  }
}
