import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/models/chart_data.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/data/models/scores_data.dart';

abstract class RemarkRepository {
  Future<Either<Failure, Map<String, List<TempRemark>>>> getRemarks();

  Future<Either<Failure, int>> getFlashcardsToReview();

  Future<Either<Failure, int>> getQuizzesToTake();

  Future<Either<Failure, String>> getAnalysis(
      Map<String, List<TempRemark>> remarks);

  Future<Either<Failure, String>> getTechniquesUsageInterpretation(
      List<ChartData> chartData);

  Future<Either<Failure, String>> getLearningMethodScoresInterpretation(
      List<ScoresData> scoresData);
}
