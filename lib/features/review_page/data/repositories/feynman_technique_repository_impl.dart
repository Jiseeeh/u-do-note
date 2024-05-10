import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/feynman_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';

class FeynmanTechniqueImpl implements FeynmanTechniqueRepository {
  final FeynmanRemoteDataSource _feynmanRemoteDataSource;

  FeynmanTechniqueImpl(this._feynmanRemoteDataSource);

  @override
  Future<Either<Failure, String>> getChatResponse(String contentFromPages,
      List<String> robotMessages, List<String> userMessages) async {
    try {
      var res = await _feynmanRemoteDataSource.getChatResponse(
          contentFromPages, robotMessages, userMessages);

      return Right(res);
    } on RequestFailedException catch (e) {
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveSession(
      FeynmanModel feynmanModel, String notebookId, String? docId) async {
    try {
      var documentId =
          await _feynmanRemoteDataSource.saveSession(feynmanModel, notebookId, docId);

      return Right(documentId);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeynmanModel>>> getOldSessions(
      String notebookId) async {
    try {
      var res = await _feynmanRemoteDataSource.getOldSessions(notebookId);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionModel>>> generateQuizQuestions(
      String content) async {
    try {
      var res = await _feynmanRemoteDataSource.generateQuizQuestions(content);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveQuizResults(
      FeynmanModel feynmanModel, String notebookId, String? newSessionName) async {
    await _feynmanRemoteDataSource.saveQuizResults(feynmanModel, notebookId, newSessionName);

    try {
      return const Right(null);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
