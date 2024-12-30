import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/active_recall/active_recall_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/domain/repositories/active_recall/active_recall_repository.dart';

class ActiveRecallImpl implements ActiveRecallRepository {
  final ActiveRecallRemoteDataSource _activeRecallRemoteDataSource;

  const ActiveRecallImpl(this._activeRecallRemoteDataSource);

  @override
  Future<Either<Failure, String>> saveQuizResults(
      ActiveRecallModel activeRecallModel) async {
    try {
      var res = await _activeRecallRemoteDataSource
          .saveQuizResults(activeRecallModel);

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
  Future<Either<Failure, String>> getActiveRecallFeedback(
      ActiveRecallModel activeRecallModel) async {
    try {
      var res = await _activeRecallRemoteDataSource
          .getActiveRecallFeedback(activeRecallModel);

      return Right(res);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while getting active recall feedback: ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFirestoreModel(
      ActiveRecallModel activeRecallModel) async {
    try {
      await _activeRecallRemoteDataSource
          .updateFirestoreModel(activeRecallModel);

      return const Right(null);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while updating firestore model: ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
