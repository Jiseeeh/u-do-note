import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner_sytem_repository.dart';

class GenerateFlashcards {
  final LeitnerSystemRepository _leitnerSystemRepository;

  GenerateFlashcards(this._leitnerSystemRepository);

  Future<Either<Failure, List<FlashcardModel>>> call(
      {required String userId, required String userNoteId}) {
    return _leitnerSystemRepository.generateFlashcards(
        userId: userId, userNoteId: userNoteId);
  }
}
