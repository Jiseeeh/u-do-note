import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/datasources/remark_remote_datasource.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class RemarkRepositoryImpl implements RemarkRepository {
  final RemarkRemoteDataSource _remarkDataSource;

  RemarkRepositoryImpl(this._remarkDataSource);

  @override
  Future<Either<Failure, List<RemarkModel>>> getRemarks() async {
    try {
      var leitnerRemarkModel = await _remarkDataSource.getRemarks();

      return Right(leitnerRemarkModel);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getFlashcardsToReview() async {
    try {
      var flashcardsToReview = await _remarkDataSource.getFlashcardsToReview();

      return Right(flashcardsToReview);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getQuizzesToTake() async {
    try {
      var quizzesToReview = await _remarkDataSource.getQuizzesToTake();

      return Right(quizzesToReview);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getAnalysis(
      List<RemarkModel> remarksModel) async {
    try {
      var analysis = await _remarkDataSource.getAnalysis(remarksModel);

      return Right(analysis);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
