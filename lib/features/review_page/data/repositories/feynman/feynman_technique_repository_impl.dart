import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/feynman/feynman_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';

import 'package:u_do_note/features/review_page/domain/repositories/feynman/feynman_technique_repository.dart';

class FeynmanTechniqueImpl implements FeynmanTechniqueRepository {
  final FeynmanRemoteDataSource _feynmanRemoteDataSource;

  FeynmanTechniqueImpl(this._feynmanRemoteDataSource);

  @override
  Future<Either<Failure, String>> getChatResponse(
      String contentFromPages, List<ChatMessage> history) async {
    try {
      var res = await _feynmanRemoteDataSource.getChatResponse(
          contentFromPages, history);

      return Right(res);
    } on RequestFailedException catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while getting chat response(openai exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while getting chat response(generic exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveSession(
      FeynmanModel feynmanModel, String notebookId, String? docId) async {
    try {
      var documentId = await _feynmanRemoteDataSource.saveSession(
          feynmanModel, notebookId, docId);

      return Right(documentId);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while saving session: ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveQuizResults(
      FeynmanModel feynmanModel,
      String notebookId,
      bool isFromOldSessionWithoutQuiz,
      String? newSessionName) async {
    await _feynmanRemoteDataSource.saveQuizResults(
        feynmanModel, notebookId, isFromOldSessionWithoutQuiz, newSessionName);

    try {
      return const Right(null);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while saving quiz results: ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
