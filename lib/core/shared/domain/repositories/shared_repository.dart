import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';

abstract class SharedRepository {
  Future<Either<Failure, List<QuestionModel>>> generateQuizQuestions(
      String content, String? customPrompt,
      {bool appendPrompt = false});

  Future<Either<Failure, List<T>>> getOldSessions<T>(
      String notebookId,
      String methodName,
      T Function(String, Map<String, dynamic>) fromFirestore,
      List<QueryFilter>? filters);
}
