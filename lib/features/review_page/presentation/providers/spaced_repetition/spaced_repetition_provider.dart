import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/spaced_repetition/spaced_repetition_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/score.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/data/repositories/spaced_repetition/spaced_repetition_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/spaced_repetition/spaced_repetition_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/spaced_repetition/save_quiz_results.dart';

part 'spaced_repetition_provider.g.dart';

@riverpod
SpacedRepetitionRemoteDataSource spacedRemoteDataSource(
    SpacedRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return SpacedRepetitionRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
SpacedRepetitionRepository spacedRepetitionRepository(
    SpacedRepetitionRepositoryRef ref) {
  final remoteDataSource = ref.read(spacedRemoteDataSourceProvider);

  return SpacedRepetitionImpl(remoteDataSource);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(spacedRepetitionRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class SpacedRepetition extends _$SpacedRepetition {
  @override
  void build() {
    return;
  }

  /// Used to save the quiz results of [SpacedRepetitionModel]
  ///
  /// Returns the saved document's ID on the first call,
  /// the subsequent calls just returns a success message.
  Future<dynamic> saveQuizResults(
      {required SpacedRepetitionModel spacedRepetitionModel}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrMessage = await saveQuizResults(spacedRepetitionModel);

    return failureOrMessage.fold((failure) => failure, (res) => res);
  }

  Future<void> onQuizFinish(
      BuildContext context,
      SpacedRepetitionModel spacedRepetitionModel,
      List<int> selectedAnswersIndex,
      int score) async {
    var spacedRepScore = ScoreModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: Timestamp.now(),
        score: score);

    SpacedRepetitionModel updatedSpacedRepModel = spacedRepetitionModel;

    if (spacedRepetitionModel.scores != null) {
      var scores = spacedRepetitionModel.scores;

      scores!.add(spacedRepScore);

      updatedSpacedRepModel = updatedSpacedRepModel.copyWith(scores: scores);
    } else {
      updatedSpacedRepModel =
          updatedSpacedRepModel.copyWith(scores: [spacedRepScore]);
    }

    var nextReview = tz.TZDateTime.now(tz.local);

    switch (updatedSpacedRepModel.scores!.length) {
      // second quiz
      case 1:
        nextReview = nextReview.add(const Duration(days: 7));
        break;
      //  third quiz
      case 2:
        nextReview = nextReview.add(const Duration(days: 16));
        break;
      //  4th quiz
      case 3:
        nextReview = nextReview.add(const Duration(days: 35));
        break;
      default:
        var sum = 0;

        for (var e in updatedSpacedRepModel.scores!) {
          sum += e.score;
        }

        var average = sum / updatedSpacedRepModel.scores!.length;
        var goodThreshold = 8.0;

        if (average >= goodThreshold) {
          // mastered, once a month
          // nextReview =
          //     nextReview.add(const Duration(days: 30)); // For once a month
          // once every 3 weeks
          nextReview = nextReview.add(const Duration(days: 21));
        } else {
          var lastScores = updatedSpacedRepModel.scores!
              .sublist(updatedSpacedRepModel.scores!.length - 4);
          var isDeclining = true;

          for (var i = 0; i < lastScores.length - 1; i++) {
            if (lastScores[i].score <= lastScores[i + 1].score) {
              isDeclining = false;
              break;
            }
          }

          if (isDeclining) {
            nextReview = nextReview.add(const Duration(days: 7));
          } else {
            nextReview = nextReview.add(const Duration(days: 3));
          }
        }
    }

    // TODO: check if selectedAnswersIndex is needed
    updatedSpacedRepModel = updatedSpacedRepModel.copyWith(
        selectedAnswersIndex: selectedAnswersIndex,
        nextReview: Timestamp.fromDate(nextReview));

    EasyLoading.show(
        status: 'Saving quiz results...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var res = await ref
        .read(spacedRepetitionProvider.notifier)
        .saveQuizResults(spacedRepetitionModel: updatedSpacedRepModel);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (res is Failure) {
      logger.e('Failed to save quiz results: ${res.message}');
      EasyLoading.showError(context.tr("save_quiz_e"));
    } else {
      logger.d(
          "Next review will be ${DateFormat("EEE, dd MMM yyyy").format(nextReview)}");
      await ref.read(localNotificationProvider).zonedSchedule(
          DateTime.now().millisecondsSinceEpoch % 100000,
          'Spaced Repetition',
          'Time to take your quiz!',
          nextReview,
          payload: json.encode(updatedSpacedRepModel.toJson()),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'quiz_notification', 'Quiz Notification',
                  channelDescription:
                      'Notifications about spaced repetition quizzes.')),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }
}
