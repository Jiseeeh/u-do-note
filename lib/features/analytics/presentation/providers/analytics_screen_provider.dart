import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:u_do_note/core/logger/logger.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/analytics/data/datasources/remark_remote_datasource.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/data/repositories/remark_repository_impl.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';
import 'package:u_do_note/features/analytics/domain/usecases/get_analysis.dart';
import 'package:u_do_note/features/analytics/domain/usecases/get_flashcards_to_review.dart';
import 'package:u_do_note/features/analytics/domain/usecases/get_quizzes_to_review.dart';
import 'package:u_do_note/features/analytics/domain/usecases/get_remarks.dart';

part 'analytics_screen_provider.g.dart';

@riverpod
RemarkRemoteDataSource remarkRemoteDataSource(Ref ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return RemarkRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
RemarkRepository remarkRepository(Ref ref) {
  var dataSource = ref.read(remarkRemoteDataSourceProvider);

  return RemarkRepositoryImpl(dataSource);
}

@riverpod
GetRemarks getRemarks(Ref ref) {
  var repository = ref.read(remarkRepositoryProvider);

  return GetRemarks(repository);
}

@riverpod
GetFlashcardsToReview getFlashcardsToReview(Ref ref) {
  var repository = ref.read(remarkRepositoryProvider);

  return GetFlashcardsToReview(repository);
}

@riverpod
GetQuizzesToTake getQuizzesToTake(Ref ref) {
  var repository = ref.read(remarkRepositoryProvider);

  return GetQuizzesToTake(repository);
}

@riverpod
GetAnalysis getAnalysis(Ref ref) {
  var repository = ref.read(remarkRepositoryProvider);

  return GetAnalysis(repository);
}

@riverpod
class AnalyticsScreen extends _$AnalyticsScreen {
  @override
  void build() {
    return;
  }

  /// Returns the remarks in all learning strategies.
  Future<List<RemarkModel>> getRemarks() async {
    final getRemarks = ref.read(getRemarksProvider);

    var failureOrRemarksModel = await getRemarks();

    return failureOrRemarksModel.fold((failure) => [], (remarks) => remarks);
  }

  /// Returns the number of flashcards to review.
  Future<dynamic> getFlashcardsToReview() async {
    final getFlashcardsToReview = ref.read(getFlashcardsToReviewProvider);

    var failureOrFlashcards = await getFlashcardsToReview();

    return failureOrFlashcards.fold(
        (failure) => "N/A", (flashcards) => flashcards);
  }

  /// Returns the number of quizzes to take.
  Future<dynamic> getQuizzesToTake() async {
    final getQuizzesToTake = ref.read(getQuizzesToTakeProvider);

    var failureOrQuizzes = await getQuizzesToTake();

    return failureOrQuizzes.fold((failure) => "N/A", (quizzes) => quizzes);
  }

  /// Analyzes the [remarksModel] and returns the analysis in json format.
  /// With the properties 'content' and 'state'.
  Future<dynamic> getAnalysis(List<RemarkModel> remarksModel) async {
    final getAnalysis = ref.read(getAnalysisProvider);

    var failureOrAnalysis = await getAnalysis(remarksModel);

    return failureOrAnalysis.fold((failure) {
      logger.w("Failed to get analysis: ${failure.message}");
      return failure;
    }, (analysis) => analysis);
  }
}
