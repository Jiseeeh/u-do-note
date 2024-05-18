import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';

abstract class RemarkRepository {
  Future<Either<Failure, List<RemarkModel>>> getRemarks();
  Future<Either<Failure, int>> getFlashcardsToReview();
  Future<Either<Failure, int>> getQuizzesToTake();
}
