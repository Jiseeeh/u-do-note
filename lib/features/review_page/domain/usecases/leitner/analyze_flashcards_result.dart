import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner/leitner_system_repository.dart';

class AnalyzeFlashcardsResult {
  final LeitnerSystemRepository _leitnerSystemRepository;

  AnalyzeFlashcardsResult(this._leitnerSystemRepository);

  Future<Either<Failure, String>> call(
      String userNotebookId, LeitnerSystemModel leitnerSystemModel) async {
    return await _leitnerSystemRepository.analyzeFlashcardsResult(
        userNotebookId, leitnerSystemModel);
  }
}
