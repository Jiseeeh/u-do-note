import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';

abstract class BlurtingRepository {
  Future<Either<Failure, String>> applyBlurtingMethod(String content);

  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, BlurtingModel blurtingModel);
}
