import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/blurting/blurting_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/repositories/blurting/blurting_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/blurting/blurting_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/blurting/apply_blurting.dart';
import 'package:u_do_note/features/review_page/domain/usecases/blurting/save_quiz_results.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';

part 'blurting_provider.g.dart';

@riverpod
BlurtingRemoteDataSource blurtingRemoteDataSource(Ref ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return BlurtingRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
BlurtingRepository blurtingRepository(Ref ref) {
  var remoteDataSource = ref.read(blurtingRemoteDataSourceProvider);

  return BlurtingImpl(remoteDataSource);
}

@riverpod
ApplyBlurting applyBlurting(Ref ref) {
  var repository = ref.read(blurtingRepositoryProvider);

  return ApplyBlurting(repository);
}

@riverpod
SaveQuizResults saveQuizResults(Ref ref) {
  var repository = ref.read(blurtingRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class Blurting extends _$Blurting {
  @override
  void build() {
    return;
  }

  /// Applies blurting method to the given [content]
  ///
  /// Returns a [Failure] or a [String]
  Future<dynamic> applyBlurting({required String content}) async {
    var applyBlurting = ref.read(applyBlurtingProvider);

    var failureOrString = await applyBlurting(content);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> saveQuizResults(
      {required String notebookId,
      required BlurtingModel blurtingModel}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrString = await saveQuizResults(notebookId, blurtingModel);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<void> onQuizFinish(BuildContext context, BlurtingModel blurtingModel,
      List<int> selectedAnswersIndex, int score) async {
    var reviewState = ref.read(reviewScreenProvider);

    var updatedBlurtingModel = blurtingModel.copyWith(
        score: score, selectedAnswersIndex: selectedAnswersIndex);

    EasyLoading.show(
        status: 'Saving quiz results...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var res = await ref.read(blurtingProvider.notifier).saveQuizResults(
        notebookId: reviewState.getNotebookId,
        blurtingModel: updatedBlurtingModel);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (res is Failure) {
      logger.e('Failed to save quiz results: ${res.message}');
      EasyLoading.showError(context.tr("save_quiz_e"));
    }
  }
}
