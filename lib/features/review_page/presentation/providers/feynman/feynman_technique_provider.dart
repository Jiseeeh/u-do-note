import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/feynman/feynman_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/repositories/feynman/feynman_technique_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman/feynman_technique_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/feynman/get_chat_response.dart';
import 'package:u_do_note/features/review_page/domain/usecases/feynman/save_quiz_results.dart';
import 'package:u_do_note/features/review_page/domain/usecases/feynman/save_session.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';

part 'feynman_technique_provider.g.dart';

@riverpod
FeynmanRemoteDataSource feynmanRemoteDataSource(Ref ref) {
  var firebaseAuth = ref.read(firebaseAuthProvider);
  var firestore = ref.read(firestoreProvider);

  return FeynmanRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
FeynmanTechniqueRepository feynmanTechniqueRepository(Ref ref) {
  final remoteDataSource = ref.read(feynmanRemoteDataSourceProvider);
  return FeynmanTechniqueImpl(remoteDataSource);
}

@riverpod
GetChatResponse getChatResponse(Ref ref) {
  final repository = ref.read(feynmanTechniqueRepositoryProvider);

  return GetChatResponse(repository);
}

@riverpod
SaveSession saveSession(Ref ref) {
  final repository = ref.read(feynmanTechniqueRepositoryProvider);

  return SaveSession(repository);
}

@riverpod
SaveQuizResults saveQuizResults(Ref ref) {
  final repository = ref.read(feynmanTechniqueRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class FeynmanTechnique extends _$FeynmanTechnique {
  @override
  void build() {
    return;
  }

  /// Get chat response from the robot in relation to the [userMessages],
  /// [robotMessages],  and the [contentFromPages],
  Future<String> getChatResponse(
      {required String contentFromPages,
      required List<ChatMessage> history}) async {
    final getChatRes = ref.read(getChatResponseProvider);

    var failureOrRes = await getChatRes(contentFromPages, history);

    return failureOrRes.fold(
        (failure) => failure.message, (chatRes) => chatRes);
  }

  /// Saves the session to the database and returns the document id or the failure.
  /// If the [docId] is not null, then it updates the document with the [docId].
  /// Otherwise, it creates a new document.
  Future<dynamic> saveSession(
      {required FeynmanModel feynmanModel,
      required String notebookId,
      String? docId}) async {
    final saveSession = ref.read(saveSessionProvider);

    var failureOrDocId = await saveSession(feynmanModel, notebookId, docId);

    return failureOrDocId.fold((failure) => failure, (docId) => docId);
  }

  /// Save the quiz data [feynmanModel] with the [notebookId] to the database.
  /// [newSessionName] is used when the user reviews an old session and started a new quiz.
  Future<dynamic> saveQuizResults(
      {required FeynmanModel feynmanModel,
      required String notebookId,
      required bool isFromOldSessionWithoutQuiz,
      String? newSessionName}) async {
    final saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrRes = await saveQuizResults(
        feynmanModel, notebookId, isFromOldSessionWithoutQuiz, newSessionName);

    return failureOrRes.fold((failure) => failure, (res) => res);
  }

  Future<void> onQuizFinish(BuildContext context, FeynmanModel feynmanModel,
      List<int> selectedAnswersIndex, int score) async {
    EasyLoading.show(
        status: 'Saving quiz results...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var updatedFeynmanModel = feynmanModel.copyWith(
        score: score, selectedAnswersIndex: selectedAnswersIndex);

    var res = await ref.read(feynmanTechniqueProvider.notifier).saveQuizResults(
        feynmanModel: updatedFeynmanModel,
        notebookId: ref.read(reviewScreenProvider).getNotebookId,
        isFromOldSessionWithoutQuiz: feynmanModel.isFromSessionWithoutQuiz,
        newSessionName: feynmanModel.newSessionName);

    EasyLoading.dismiss();

    if (res is Failure) {
      logger.e("Error saving: ${res.message}");
      EasyLoading.showError(res.message);
    }
  }
}
