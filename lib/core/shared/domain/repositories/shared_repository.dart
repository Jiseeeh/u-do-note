import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';

abstract class SharedRepository {
  Future<Either<Failure, List<QuestionModel>>> generateQuizQuestions(
      String content, String? customPrompt,
      {bool appendPrompt = false});
}
