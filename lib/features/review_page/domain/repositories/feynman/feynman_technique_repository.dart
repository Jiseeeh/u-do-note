import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';

abstract class FeynmanTechniqueRepository {
  Future<Either<Failure, String>> getChatResponse(
      String contentFromPages, List<ChatMessage> history);

  Future<Either<Failure, String>> saveSession(
      FeynmanModel feynmanModel, String notebookId, String? docId);

  Future<Either<Failure, void>> saveQuizResults(
      FeynmanModel feynmanModel,
      String notebookId,
      bool isFromOldSessionWithoutQuiz,
      String? newSessionName);
}
