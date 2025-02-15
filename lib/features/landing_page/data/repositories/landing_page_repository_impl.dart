import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/landing_page/data/datasources/landing_page_remote_datasource.dart';
import 'package:u_do_note/features/landing_page/domain/repositories/landing_page_repository.dart';

class LandingPageImpl implements LandingPageRepository {
  final LandingPageRemoteDataSource _landingPageRemoteDataSource;

  const LandingPageImpl(this._landingPageRemoteDataSource);

  @override
  Future<Either<Failure, List<T>>> getOnGoingReviews<T>(String methodName,
      T Function(String p1, Map<String, dynamic> p2) fromFirestore) async {
    try {
      var res = await _landingPageRemoteDataSource.getOnGoingReviews(
          methodName, fromFirestore);

      return Right(res);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while fetching on going reviews from the remote data source: ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBrokenBlurtingRemark(
      String notebookId, String blurtingRemarkId) async {
    try {
      var res = await _landingPageRemoteDataSource.deleteBrokenBlurtingRemark(
          notebookId, blurtingRemarkId);

      return Right(res);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while deleting broken blurting remark from the remote data source: ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
