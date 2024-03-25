import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner_system_repository.dart';

class GenerateFlashcards {
  final LeitnerSystemRepository _leitnerSystemRepository;

  GenerateFlashcards(this._leitnerSystemRepository);

  Future<Either<Failure, LeitnerSystemModel>> call(
      String title, String userNotebookId, String content) async {
    return await _leitnerSystemRepository.generateFlashcards(
        title, userNotebookId, content);
  }
}
