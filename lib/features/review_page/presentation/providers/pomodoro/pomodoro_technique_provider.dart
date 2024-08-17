import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/pomodoro/pomdoro_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/data/repositories/pomodoro/pomodoro_technique_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/entities/pomodoro/pomodoro_state.dart';
import 'package:u_do_note/features/review_page/domain/repositories/pomodoro/pomodoro_technique_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/pomodoro/save_quiz_results.dart';

part 'pomodoro_technique_provider.g.dart';

@riverpod
PomodoroRemoteDataSource pomodoroTechniqueDataSource(
    PomodoroTechniqueDataSourceRef ref) {
  var firebaseAuth = ref.read(firebaseAuthProvider);
  var firestore = ref.read(firestoreProvider);

  return PomodoroRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
PomodoroTechniqueRepository pomodoroTechniqueRepository(
    PomodoroTechniqueRepositoryRef ref) {
  final remoteDataSource = ref.read(pomodoroTechniqueDataSourceProvider);

  return PomodoroTechniqueRepositoryImpl(remoteDataSource);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(pomodoroTechniqueRepositoryProvider);

  return SaveQuizResults(repository);
}

@Riverpod(keepAlive: true)
class Pomodoro extends _$Pomodoro {
  @override
  PomodoroState build() {
    return PomodoroState();
  }

  Future<dynamic> saveQuizResults(
      String notebookId, PomodoroModel pomodoroModel) async {
    var saveQuizResultsUseCase = ref.read(saveQuizResultsProvider);

    var failureOrString =
        await saveQuizResultsUseCase(notebookId, pomodoroModel);

    return failureOrString.fold((failure) => failure, (res) => res);
  }
}
