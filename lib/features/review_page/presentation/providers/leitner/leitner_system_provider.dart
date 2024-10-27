import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/leitner/leitner_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/repositories/leitner/leitner_system_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner/leitner_system_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/leitner/analyze_flashcards_result.dart';
import 'package:u_do_note/features/review_page/domain/usecases/leitner/generate_flashcards.dart';

part 'leitner_system_provider.g.dart';

@riverpod
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
LeitnerRemoteDataSource leitnerSystemRemoteDataSource(Ref ref) {
  final firestore = ref.read(firestoreProvider);

  return LeitnerRemoteDataSource(firestore);
}

@riverpod
LeitnerSystemRepository leitnerSystemRepository(Ref ref) {
  final remoteDataSource = ref.read(leitnerSystemRemoteDataSourceProvider);

  return LeitnerSystemImpl(remoteDataSource);
}

@riverpod
GenerateFlashcards generateFlashcards(Ref ref) {
  final repository = ref.read(leitnerSystemRepositoryProvider);

  return GenerateFlashcards(repository);
}

@riverpod
AnalyzeFlashcardsResult analyzeFlashcardsResult(Ref ref) {
  final repository = ref.read(leitnerSystemRepositoryProvider);

  return AnalyzeFlashcardsResult(repository);
}

@riverpod
class LeitnerSystem extends _$LeitnerSystem {
  @override
  void build() {
    return;
  }

  // TODO: check if we can already fold the result here
  /// Generate flashcards based on the given [content].
  Future<Either<Failure, LeitnerSystemModel>> generateFlashcards(
      String title, String userNotebookId, String content) async {
    final generateFlashcards = ref.read(generateFlashcardsProvider);

    return await generateFlashcards(title, userNotebookId, content);
  }

  /// Analyzes the results of leitner system based on the response times
  /// from the flashcards.
  Future<String> analyzeFlashcardsResult(
      String userNotebookId, LeitnerSystemModel leitnerSystemModel) async {
    final analyzeFlashcardsResult = ref.read(analyzeFlashcardsResultProvider);

    var failureOrString =
        await analyzeFlashcardsResult(userNotebookId, leitnerSystemModel);

    return failureOrString.fold(
        (failure) => failure.message, (result) => result);
  }
}
