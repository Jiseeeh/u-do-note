import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/domain/repositories/elaboration_repository.dart';

class ESaveQuizResults {
  final ElaborationRepository _elaborationRepository;

  const ESaveQuizResults(this._elaborationRepository);

  Future<Either<Failure, void>> call(
      String notebookId, ElaborationModel elaborationModel) async {
    return await _elaborationRepository.saveQuizResults(
        notebookId, elaborationModel);
  }
}
