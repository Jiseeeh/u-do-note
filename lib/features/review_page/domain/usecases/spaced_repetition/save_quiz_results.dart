import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/domain/repositories/spaced_repetition/spaced_repetition_repository.dart';

class SaveQuizResults {
  final SpacedRepetitionRepository _spacedRepetitionRepository;

  const SaveQuizResults(this._spacedRepetitionRepository);

  Future<Either<Failure, String>> call(
      SpacedRepetitionModel spacedRepetitionModel) async {
    return await _spacedRepetitionRepository
        .saveQuizResults(spacedRepetitionModel);
  }
}
