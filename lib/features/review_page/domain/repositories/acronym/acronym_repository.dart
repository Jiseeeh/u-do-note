import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';

abstract class AcronymRepository {
  Future<Either<Failure, String>> generateAcronymMnemonics(String content);

  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, AcronymModel acronymModel);
}
