import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/domain/repositories/sq3r/sq3r_repository.dart';

class GetSq3rFeedback {
  final Sq3rRepository _sq3rRepository;

  const GetSq3rFeedback(this._sq3rRepository);

  Future<Either<Failure, String>> call(
      String noteContextWithSummary, String questionAndAnswers) async {
    return await _sq3rRepository.getSq3rFeedback(
        noteContextWithSummary, questionAndAnswers);
  }
}
