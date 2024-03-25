import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner_system_repository.dart';

class GetOldFlashcards {
  final LeitnerSystemRepository _repository;

  GetOldFlashcards(this._repository);

  Future<Either<Failure, List<LeitnerSystemModel>>> call(String notebookId) async {
    return await _repository.getOldFlashcards(notebookId);
  }
}