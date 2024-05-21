import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class GetFlashcardsToReview {
  final RemarkRepository _remarkRepository;

  GetFlashcardsToReview(this._remarkRepository);

  Future<Either<Failure, int>> call() async {
    return await _remarkRepository.getFlashcardsToReview();
  }
}
