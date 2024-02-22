import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';

abstract class LeitnerSystemRepository {
  Future<Either<Failure, List<FlashcardModel>>> generateFlashcards(
      {required String userId, required String userNoteId});
}
