import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/domain/repositories/shared_repository.dart';

class GenerateXqrFeedback {
  final SharedRepository _sharedRepository;

  const GenerateXqrFeedback(this._sharedRepository);

  Future<Either<Failure, String>> call(
      String noteContextWithSummary, String questionAndAnswers) async {
    return await _sharedRepository.generateXqrFeedback(
        noteContextWithSummary, questionAndAnswers);
  }
}
