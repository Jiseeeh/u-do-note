import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/pomodoro/pomdoro_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/domain/repositories/pomodoro/pomodoro_technique_repository.dart';

class PomodoroTechniqueRepositoryImpl implements PomodoroTechniqueRepository {
  final PomodoroRemoteDataSource _pomodoroRemoteDataSource;

  PomodoroTechniqueRepositoryImpl(this._pomodoroRemoteDataSource);

  @override
  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, PomodoroModel pomodoroModel) async {
    try {
      var res = await _pomodoroRemoteDataSource.saveQuizResults(
          notebookId, pomodoroModel);
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
}
