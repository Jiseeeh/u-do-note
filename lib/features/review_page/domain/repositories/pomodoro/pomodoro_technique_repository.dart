import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';

abstract class PomodoroTechniqueRepository {
  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, PomodoroModel pomodoroModel);
}
