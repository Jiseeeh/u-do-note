import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/spaced_repetition/spaced_repetition_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/data/repositories/spaced_repetition/spaced_repetition_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/spaced_repetition/spaced_repetition_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/spaced_repetition/save_quiz_results.dart';

part 'spaced_repetition_provider.g.dart';

@riverpod
SpacedRepetitionRemoteDataSource spacedRemoteDataSource(
    SpacedRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return SpacedRepetitionRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
SpacedRepetitionRepository spacedRepetitionRepository(
    SpacedRepetitionRepositoryRef ref) {
  final remoteDataSource = ref.read(spacedRemoteDataSourceProvider);

  return SpacedRepetitionImpl(remoteDataSource);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(spacedRepetitionRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class SpacedRepetition extends _$SpacedRepetition {
  @override
  void build() {
    return;
  }

  /// Used to save the quiz results of [SpacedRepetitionModel]
  ///
  /// Returns the saved document's ID on the first call,
  /// the subsequent calls just returns a success message.
  Future<dynamic> saveQuizResults(
      {required SpacedRepetitionModel spacedRepetitionModel}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrMessage = await saveQuizResults(spacedRepetitionModel);

    return failureOrMessage.fold((failure) => failure, (res) => res);
  }
}
