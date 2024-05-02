import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';

abstract class FeynmanTechniqueRepository {
  Future<Either<Failure, String>> getChatResponse(String contentFromPages,
      List<String> robotMessages, List<String> userMessages);

  Future<Either<Failure, void>> saveSession(
      FeynmanModel feynmanModel, String notebookId);
  Future<Either<Failure, List<FeynmanModel>>> getOldSessions(String notebookId);
}
