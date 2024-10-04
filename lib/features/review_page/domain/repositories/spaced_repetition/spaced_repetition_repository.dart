import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';

abstract class SpacedRepetitionRepository {
  Future<Either<Failure, String>> generateContent(
      String content, AssistanceType type);

  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, SpacedRepetitionModel spacedRepetitionModel);
}