import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';

abstract class LeitnerSystemRepository {
  Future<Either<Failure, LeitnerSystemModel>> generateFlashcards(
      String userNotebookId, String content);
  Future<Either<Failure, String>> analyzeFlashcardsResult(
      String userNotebookId, LeitnerSystemModel leitnerSystemModel);
}
