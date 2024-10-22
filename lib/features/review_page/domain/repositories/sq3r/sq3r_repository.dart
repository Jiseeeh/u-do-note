import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';

abstract class Sq3rRepository {
  Future<Either<Failure, String>> getSq3rFeedback(
      String noteContextWithSummary, String questionAndAnswers);

  Future<Either<Failure, String>> saveQuizResults(Sq3rModel sq3rModel);
}
