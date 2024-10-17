import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/active_recall/active_recall_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/repositories/active_recall/active_recall_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/active_recall/active_recall_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/active_recall/get_active_recall_feedback.dart';
import 'package:u_do_note/features/review_page/domain/usecases/active_recall/save_quiz_results.dart';
import 'package:u_do_note/features/review_page/domain/usecases/active_recall/update_firestore_model.dart';

part 'active_recall_provider.g.dart';

@riverpod
ActiveRecallRemoteDataSource activeRecallRemoteDataSource(
    ActiveRecallRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return ActiveRecallRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
ActiveRecallRepository activeRecallRepository(ActiveRecallRepositoryRef ref) {
  final remoteDataSource = ref.read(activeRecallRemoteDataSourceProvider);

  return ActiveRecallImpl(remoteDataSource);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(activeRecallRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
GetActiveRecallFeedback getActiveRecallFeedback(
    GetActiveRecallFeedbackRef ref) {
  final repository = ref.read(activeRecallRepositoryProvider);

  return GetActiveRecallFeedback(repository);
}

@riverpod
UpdateFirestoreModel updateFirestoreModel(UpdateFirestoreModelRef ref) {
  final repository = ref.read(activeRecallRepositoryProvider);

  return UpdateFirestoreModel(repository);
}

@riverpod
class ActiveRecall extends _$ActiveRecall {
  @override
  void build() {
    return;
  }

  /// Used to save the quiz results of [SpacedRepetitionModel]
  ///
  /// Returns the saved document's ID on the first call,
  /// the subsequent calls returns the days before the next_review.
  ///
  /// Or a [Failure]
  Future<dynamic> saveQuizResults(
      {required ActiveRecallModel activeRecallModel}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrMessage = await saveQuizResults(activeRecallModel);

    return failureOrMessage.fold((failure) => failure, (res) => res);
  }

  /// Returns a JSON string containing "feedback", and "days"
  ///
  /// Or a [Failure]
  Future<dynamic> getActiveRecallFeedback(
      ActiveRecallModel activeRecallModel, String recalledInformation) async {
    var getActiveRecallFeedback = ref.read(getActiveRecallFeedbackProvider);

    var failureOrJsonStr =
        await getActiveRecallFeedback(activeRecallModel, recalledInformation);

    return failureOrJsonStr.fold((failure) => failure, (res) => res);
  }

  /// Updates the firestore model with the given [activeRecallModel]
  Future<dynamic> updateFirestoreModel(
      ActiveRecallModel activeRecallModel) async {
    {
      var updateFirestoreModel = ref.read(updateFirestoreModelProvider);

      var failureOrNull = await updateFirestoreModel(activeRecallModel);

      return failureOrNull.fold((failure) => failure, (res) => res);
    }
  }
}
