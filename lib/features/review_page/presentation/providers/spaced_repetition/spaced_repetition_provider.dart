import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/spaced_repetition/spaced_repetition_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/data/repositories/spaced_repetition/spaced_repetition_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/spaced_repetition/spaced_repetition_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/spaced_repetition/generate_content.dart';
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
GenerateContent generateContent(GenerateContentRef ref) {
  final repository = ref.read(spacedRepetitionRepositoryProvider);

  return GenerateContent(repository);
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

  Future<dynamic> generateContent(
      {required AssistanceType type, required String content}) async {
    var generateContent = ref.read(generateContentProvider);

    var failureOrContent = await generateContent(type, content);

    return failureOrContent.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> saveQuizResults(
      {required String notebookId,
      required SpacedRepetitionModel spacedRepetitionModel}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrMessage =
        await saveQuizResults(notebookId, spacedRepetitionModel);

    return failureOrMessage.fold((failure) => failure, (res) => res);
  }
}