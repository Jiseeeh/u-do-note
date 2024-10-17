import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';

abstract class ActiveRecallRepository {
  Future<Either<Failure, String>> saveQuizResults(
      ActiveRecallModel activeRecallModel);

  Future<Either<Failure, String>> getActiveRecallFeedback(
      ActiveRecallModel activeRecallModel, String recalledInformation);

  Future<Either<Failure, void>> updateFirestoreModel(
      ActiveRecallModel activeRecallModel);
}
