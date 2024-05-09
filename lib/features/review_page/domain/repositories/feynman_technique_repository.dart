import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';

abstract class FeynmanTechniqueRepository {
  Future<Either<Failure, String>> getChatResponse(String contentFromPages,
      List<String> robotMessages, List<String> userMessages);

  Future<Either<Failure, String>> saveSession(
      FeynmanModel feynmanModel, String notebookId, String? docId);
  Future<Either<Failure, List<FeynmanModel>>> getOldSessions(String notebookId);
  Future<Either<Failure, List<QuestionModel>>> generateQuizQuestions(
      String content);
  Future<Either<Failure, void>> saveQuizResults(
      FeynmanModel feynmanModel, String notebookId, String? newSessionName);
}
