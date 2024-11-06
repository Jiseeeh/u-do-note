import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';

abstract class SpacedRepetitionRepository {
  Future<Either<Failure, String>> saveQuizResults(
      SpacedRepetitionModel spacedRepetitionModel);
}
