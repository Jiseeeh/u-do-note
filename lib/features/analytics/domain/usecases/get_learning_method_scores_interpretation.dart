import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/models/scores_data.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class GetLearningMethodScoresInterpretation {
  final RemarkRepository _remarkRepository;

  const GetLearningMethodScoresInterpretation(this._remarkRepository);

  Future<Either<Failure, String>> call(List<ScoresData> scoresData) async {
    return await _remarkRepository
        .getLearningMethodScoresInterpretation(scoresData);
  }
}
