import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/acronym/acronym_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/repositories/acronym/acronym_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/acronym/acronym_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/acronym/generate_acronym_mnemonics.dart';
import 'package:u_do_note/features/review_page/domain/usecases/acronym/save_quiz_results.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';

part 'acronym_provider.g.dart';

@riverpod
AcronymRemoteDataSource acronymRemoteDataSource(
    AcronymRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return AcronymRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
AcronymRepository acronymRepository(AcronymRepositoryRef ref) {
  final remoteDataSource = ref.read(acronymRemoteDataSourceProvider);

  return AcronymImpl(remoteDataSource);
}

@riverpod
GenerateAcronymMnemonics generateAcronymMnemonics(
    GenerateAcronymMnemonicsRef ref) {
  final repository = ref.read(acronymRepositoryProvider);

  return GenerateAcronymMnemonics(repository);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(acronymRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class Acronym extends _$Acronym {
  @override
  void build() {
    return;
  }

  /// Generates Acronym Mnemonics about the given [content]
  Future<dynamic> generateAcronymMnemonics({required String content}) async {
    var generateAcronymMnemonics = ref.read(generateAcronymMnemonicsProvider);

    var failureOrContent = await generateAcronymMnemonics(content);

    return failureOrContent.fold((failure) => failure, (content) => content);
  }

  Future<dynamic> saveQuizResults(
      {required String notebookId, required AcronymModel acronymModel}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrString = await saveQuizResults(notebookId, acronymModel);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<void> onQuizFinish(BuildContext context, AcronymModel acronymModel,
      List<int> selectedAnswersIndex, int score) async {
    var reviewState = ref.read(reviewScreenProvider);

    var updatedAcronymModel = acronymModel.copyWith(
        sessionName: reviewState.getSessionTitle,
        createdAt: Timestamp.now(),
        score: score,
        selectedAnswersIndex: selectedAnswersIndex);

    EasyLoading.show(
        status: 'Saving quiz results...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var res = await ref.read(acronymProvider.notifier).saveQuizResults(
        notebookId: reviewState.getNotebookId,
        acronymModel: updatedAcronymModel);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (res is Failure) {
      logger.e('Failed to save quiz results: ${res.message}');
      EasyLoading.showError(context.tr("save_quiz_e"));
    }
  }
}
