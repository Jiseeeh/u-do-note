import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/leitner_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/repositories/leitner_system_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner_system_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/analyze_flashcards_result.dart';
import 'package:u_do_note/features/review_page/domain/usecases/generate_flashcards.dart';
import 'package:u_do_note/features/review_page/domain/usecases/get_old_flashcards.dart';

part 'leitner_system_provider.g.dart';

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
LeitnerRemoteDataSource leitnerSystemRemoteDataSource(
    LeitnerSystemRemoteDataSourceRef ref) {
  final firestore = ref.read(firestoreProvider);

  return LeitnerRemoteDataSource(firestore);
}

@riverpod
LeitnerSystemRepository leitnerSystemRepository(
    LeitnerSystemRepositoryRef ref) {
  final remoteDataSource = ref.read(leitnerSystemRemoteDataSourceProvider);

  return LeitnerSystemImpl(remoteDataSource);
}

@riverpod
GenerateFlashcards generateFlashcards(GenerateFlashcardsRef ref) {
  final repository = ref.read(leitnerSystemRepositoryProvider);

  return GenerateFlashcards(repository);
}

@riverpod
AnalyzeFlashcardsResult analyzeFlashcardsResult(
    AnalyzeFlashcardsResultRef ref) {
  final repository = ref.read(leitnerSystemRepositoryProvider);

  return AnalyzeFlashcardsResult(repository);
}

@riverpod
GetOldFlashcards getOldFlashcards(GetOldFlashcardsRef ref) {
  final repository = ref.read(leitnerSystemRepositoryProvider);

  return GetOldFlashcards(repository);
}

@riverpod
class LeitnerSystem extends _$LeitnerSystem {
  @override
  void build() {
    return;
  }

  // TODO: check if we can already fold the result here
  Future<Either<Failure, LeitnerSystemModel>> generateFlashcards(
      String title, String userNotebookId, String content) async {
    final generateFlashcards = ref.read(generateFlashcardsProvider);

    return await generateFlashcards(title, userNotebookId, content);
  }

  Future<String> analyzeFlashcardsResult(
      String userNotebookId, LeitnerSystemModel leitnerSystemModel) async {
    final analyzeFlashcardsResult = ref.read(analyzeFlashcardsResultProvider);

    var failureOrString =
        await analyzeFlashcardsResult(userNotebookId, leitnerSystemModel);

    return failureOrString.fold(
        (failure) => failure.message, (result) => result);
  }

  Future<List<LeitnerSystemModel>> getOldFlashcards(String notebookId) async {
    final getOldFlashcards = ref.read(getOldFlashcardsProvider);

    var failureOrFlashcards = await getOldFlashcards(notebookId);

    return failureOrFlashcards.fold((failure) {
      return [];
    }, (leitnerModels) {
      return leitnerModels;
    });
  }
}
