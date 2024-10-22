import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/sq3r/sq3r_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';
import 'package:u_do_note/features/review_page/data/repositories/sq3r/sq3r_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/sq3r/sq3r_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/sq3r/get_sq3r_feedback.dart';
import 'package:u_do_note/features/review_page/domain/usecases/sq3r/save_quiz_results.dart';

part 'sq3r_provider.g.dart';

@riverpod
Sq3rRemoteDataSource sq3rRemoteDataSource(Sq3rRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return Sq3rRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
Sq3rRepository sq3rRepository(Sq3rRepositoryRef ref) {
  final remoteDataSource = ref.read(sq3rRemoteDataSourceProvider);

  return Sq3rImpl(remoteDataSource);
}

@riverpod
GetSq3rFeedback getSq3rFeedback(GetSq3rFeedbackRef ref) {
  final repository = ref.read(sq3rRepositoryProvider);

  return GetSq3rFeedback(repository);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(sq3rRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class Sq3r extends _$Sq3r {
  @override
  void build() {
    return;
  }

  /// Generates feedback based on [noteContextWithSummary]
  /// and [questionAndAnswers] of the user.
  ///
  /// Returns "acknowledgement" as a string,
  /// "missed" as as string,
  /// "suggestions" as string, and
  /// "isValid" as boolean
  Future<dynamic> getSq3rFeedback(
      {required String noteContextWithSummary,
      required String questionAndAnswers}) async {
    var getSq3rFeedback = ref.read(getSq3rFeedbackProvider);

    var failureOrJsonContent =
        await getSq3rFeedback(noteContextWithSummary, questionAndAnswers);

    return failureOrJsonContent.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> saveQuizResults(Sq3rModel sq3rModel) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrMessage = await saveQuizResults(sq3rModel);

    return failureOrMessage.fold((failure) => failure, (res) => res);
  }
}
