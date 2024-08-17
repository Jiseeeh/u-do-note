import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/domain/repositories/pomodoro/pomodoro_technique_repository.dart';

class SaveQuizResults {
  final PomodoroTechniqueRepository _pomodoroTechniqueRepository;

  SaveQuizResults(this._pomodoroTechniqueRepository);

  Future<Either<Failure, String>> call(
      String notebookId, PomodoroModel pomodoroModel) async {
    return await _pomodoroTechniqueRepository.saveQuizResults(
        notebookId, pomodoroModel);
  }
}
