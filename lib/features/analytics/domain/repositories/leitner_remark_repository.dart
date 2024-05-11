import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/models/leitner_remark.dart';

abstract class LeitnerSystemRemarkRepository {
  Future<Either<Failure, LeitnerSystemRemarkModel>> getLeitnerSystemRemarks();
}
