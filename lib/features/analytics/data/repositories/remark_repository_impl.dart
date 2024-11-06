import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/datasources/remark_remote_datasource.dart';
import 'package:u_do_note/features/analytics/data/models/chart_data.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/data/models/scores_data.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class RemarkRepositoryImpl implements RemarkRepository {
  final RemarkRemoteDataSource _remarkDataSource;

  RemarkRepositoryImpl(this._remarkDataSource);

  @override
  Future<Either<Failure, Map<String, List<RemarkModel>>>> getRemarks() async {
    try {
      var remarks = await _remarkDataSource.getRemarks();

      return Right(remarks);
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
      Map<String, List<RemarkModel>> remarks) async {
    try {
      var analysis = await _remarkDataSource.getAnalysis(remarks);

      return Right(analysis);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getTechniquesUsageInterpretation(
      List<ChartData> chartData) async {
    try {
      var interpretation =
          await _remarkDataSource.getTechniquesUsageInterpretation(chartData);

      return Right(interpretation);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getLearningMethodScoresInterpretation(
      List<ScoresData> scoresData) async {
    try {
      var interpretation = await _remarkDataSource
          .getLearningMethodScoresInterpretation(scoresData);

      return Right(interpretation);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
