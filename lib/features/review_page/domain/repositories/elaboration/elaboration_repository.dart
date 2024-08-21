import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';

abstract class ElaborationRepository {
  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, ElaborationModel elaborationModel);

  Future<Either<Failure, String>> getElaboratedContent(String content);
}
