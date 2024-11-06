import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/elaboration/elaboration_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/repositories/elaboration/elaboration_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/elaboration/elaboration_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/elaboration/get_elaborated_content.dart';
import 'package:u_do_note/features/review_page/domain/usecases/elaboration/save_quiz_results.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';

part 'elaboration_provider.g.dart';

@riverpod
ElaborationRemoteDataSource elaborationRemoteDataSource(Ref ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return ElaborationRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
ElaborationRepository elaborationRepository(Ref ref) {
  final remoteDataSource = ref.read(elaborationRemoteDataSourceProvider);

  return ElaborationImpl(remoteDataSource);
}

@riverpod
SaveQuizResults saveQuizResults(Ref ref) {
  final repository = ref.read(elaborationRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
GetElaboratedContent getElaboratedContent(Ref ref) {
  final repository = ref.read(elaborationRepositoryProvider);

  return GetElaboratedContent(repository);
}

@riverpod
class Elaboration extends _$Elaboration {
  @override
  void build() {
    return;
  }

  /// Save the quiz results
  /// This also be used to save the remark when the user has not taken the quiz
  Future<dynamic> saveQuizResults(
      String notebookId, ElaborationModel elaborationModel) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrString = await saveQuizResults(notebookId, elaborationModel);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  /// Elaborates the given [content]
  Future<dynamic> getElaboratedContent({required String content}) async {
    var getElaboratedContent = ref.read(getElaboratedContentProvider);

    var failureOrContent = await getElaboratedContent(content);

    return failureOrContent.fold((failure) => failure, (content) => content);
  }

  Future<void> onQuizFinish(
      BuildContext context,
      ElaborationModel elaborationModel,
      List<int> selectedAnswersIndex,
      int score) async {
    var reviewState = ref.read(reviewScreenProvider);

    var updatedElaborationModel = elaborationModel.copyWith(
        sessionName: reviewState.getSessionTitle,
        createdAt: Timestamp.now(),
        score: score,
        selectedAnswersIndex: selectedAnswersIndex);

    EasyLoading.show(
        status: 'Saving quiz results...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var res = await ref
        .read(elaborationProvider.notifier)
        .saveQuizResults(reviewState.getNotebookId, updatedElaborationModel);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (res is Failure) {
      logger.e('Failed to save quiz results: ${res.message}');
      EasyLoading.showError(context.tr("save_quiz_e"));
    }
  }
}
