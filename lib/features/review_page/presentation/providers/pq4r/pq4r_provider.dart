import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/pq4r/pq4r_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/features/review_page/data/repositories/pq4r/pq4r_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/pq4r/pq4r_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/pq4r/save_quiz_results.dart';

part 'pq4r_provider.g.dart';

@riverpod
Pq4rRemoteDataSource pq4rRemoteDataSource(Ref ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return Pq4rRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
Pq4rRepository pq4rRepository(Ref ref) {
  final remoteDataSource = ref.read(pq4rRemoteDataSourceProvider);

  return Pq4rImpl(remoteDataSource);
}

@riverpod
SaveQuizResults saveQuizResults(Ref ref) {
  final repository = ref.read(pq4rRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class Pq4r extends _$Pq4r {
  @override
  void build() {
    return;
  }

  Future<dynamic> saveQuizResults(Pq4rModel pq4rModel) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrMessage = await saveQuizResults(pq4rModel);

    return failureOrMessage.fold((failure) => failure, (res) => res);
  }

  Future<void> onQuizFinish(BuildContext context, Pq4rModel pq4rModel,
      List<int> selectedAnswersIndex, int score) async {
    var updatedPq4rModel = pq4rModel.copyWith(
        score: score, selectedAnswersIndex: selectedAnswersIndex);

    EasyLoading.show(
        status: 'Saving quiz results...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var failureOrMessage =
        await ref.read(pq4rProvider.notifier).saveQuizResults(updatedPq4rModel);

    if (!context.mounted) return;

    if (failureOrMessage is Failure) {
      logger.e('Failed to save quiz results: ${failureOrMessage.message}');
      EasyLoading.showError(context.tr("save_quiz_e"));
    }

    EasyLoading.dismiss();
  }
}
