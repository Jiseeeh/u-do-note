import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/elaboration/elaboration_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/domain/repositories/elaboration/elaboration_repository.dart';

class ElaborationImpl implements ElaborationRepository {
  final ElaborationRemoteDataSource _elaborationRemoteDataSource;

  const ElaborationImpl(this._elaborationRemoteDataSource);

  @override
  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, ElaborationModel elaborationModel) async {
    try {
      var res = await _elaborationRemoteDataSource.saveQuizResults(
          notebookId, elaborationModel);

      return Right(res);
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

  @override
  Future<Either<Failure, String>> getElaboratedContent(String content) async {
    try {
      var res =
          await _elaborationRemoteDataSource.getElaboratedContent(content);

      return Right(res);
    } on RequestFailedException catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while getting elaborated content(openai exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while getting elaborated content(generic exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
