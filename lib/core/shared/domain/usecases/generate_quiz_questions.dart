import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/domain/repositories/shared_repository.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';

class GenerateQuizQuestions {
  final SharedRepository _sharedRepository;

  const GenerateQuizQuestions(this._sharedRepository);

  Future<Either<Failure, List<QuestionModel>>> call(
      String content, String? customPrompt,
      {bool appendPrompt = false}) async {
    return await _sharedRepository.generateQuizQuestions(content, customPrompt,
        appendPrompt: appendPrompt);
  }
}
