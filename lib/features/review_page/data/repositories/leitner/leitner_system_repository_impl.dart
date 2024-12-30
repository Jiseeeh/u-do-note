import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/leitner/leitner_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner/leitner_system_repository.dart';

class LeitnerSystemImpl implements LeitnerSystemRepository {
  final LeitnerRemoteDataSource _leitnerRemoteDataSource;

  LeitnerSystemImpl(this._leitnerRemoteDataSource);

  @override
  Future<Either<Failure, LeitnerSystemModel>> generateFlashcards(
      String title, String userNotebookId, String content) async {
    try {
      final leitnerSystemModel = await _leitnerRemoteDataSource
          .generateFlashcards(title, userNotebookId, content);

      return Right(leitnerSystemModel);
    } on RequestFailedException catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while generating flashcards(openai exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while generating flashcards(generic exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> analyzeFlashcardsResult(
      String userNotebookId, LeitnerSystemModel leitnerSystemModel) async {
    try {
      var res = await _leitnerRemoteDataSource.analyzeFlashcardsResult(
          userNotebookId, leitnerSystemModel);

      return Right(res);
    } on RequestFailedException catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while analyzing flashcards result(openai exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while analyzing flashcards result(generic exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
