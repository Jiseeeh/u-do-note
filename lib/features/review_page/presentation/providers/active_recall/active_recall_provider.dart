import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/review_page/data/datasources/active_recall/active_recall_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/models/score.dart';
import 'package:u_do_note/features/review_page/data/repositories/active_recall/active_recall_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/active_recall/active_recall_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/active_recall/get_active_recall_feedback.dart';
import 'package:u_do_note/features/review_page/domain/usecases/active_recall/save_quiz_results.dart';
import 'package:u_do_note/features/review_page/domain/usecases/active_recall/update_firestore_model.dart';

part 'active_recall_provider.g.dart';

@riverpod
ActiveRecallRemoteDataSource activeRecallRemoteDataSource(Ref ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return ActiveRecallRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
ActiveRecallRepository activeRecallRepository(Ref ref) {
  final remoteDataSource = ref.read(activeRecallRemoteDataSourceProvider);

  return ActiveRecallImpl(remoteDataSource);
}

@riverpod
SaveQuizResults saveQuizResults(Ref ref) {
  final repository = ref.read(activeRecallRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
GetActiveRecallFeedback getActiveRecallFeedback(Ref ref) {
  final repository = ref.read(activeRecallRepositoryProvider);

  return GetActiveRecallFeedback(repository);
}

@riverpod
UpdateFirestoreModel updateFirestoreModel(Ref ref) {
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
      ActiveRecallModel activeRecallModel) async {
    var getActiveRecallFeedback = ref.read(getActiveRecallFeedbackProvider);

    var failureOrJsonStr = await getActiveRecallFeedback(activeRecallModel);

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

  Future<void> onQuizFinish(
      BuildContext context,
      ActiveRecallModel activeRecallModel,
      List<int> selectedAnswersIndex,
      int score) async {
    var activeRecallScore = ScoreModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: Timestamp.now(),
        score: score);

    ActiveRecallModel updatedActiveRecallModel = activeRecallModel;

    if (activeRecallModel.scores != null) {
      var scores = activeRecallModel.scores;

      scores!.add(activeRecallScore);

      updatedActiveRecallModel =
          updatedActiveRecallModel.copyWith(scores: scores);
    } else {
      updatedActiveRecallModel =
          updatedActiveRecallModel.copyWith(scores: [activeRecallScore]);
    }

    EasyLoading.show(
        status: 'Saving quiz results...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var failureOrSuccessMessage = await ref
        .read(activeRecallProvider.notifier)
        .saveQuizResults(activeRecallModel: updatedActiveRecallModel);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (failureOrSuccessMessage is Failure) {
      logger
          .e('Failed to save quiz results: ${failureOrSuccessMessage.message}');
      EasyLoading.showError(context.tr("save_quiz_e"));
    }

    EasyLoading.show(
        status: 'Getting feedback...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var failureOrJsonStr = await ref
        .read(activeRecallProvider.notifier)
        .getActiveRecallFeedback(updatedActiveRecallModel);

    if (!context.mounted) return;

    EasyLoading.dismiss();

    if (failureOrJsonStr is Failure) {
      logger
          .e('Failed to get the feedback: ${failureOrSuccessMessage.message}');
      EasyLoading.showError("Something went wrong when getting the feedback.");
    } else {
      var decodedJson = json.decode(failureOrJsonStr);
      var feedback = decodedJson['feedback'];
      var nextReviewDays = decodedJson['days'];
      var nextReview = tz.TZDateTime.now(tz.local);

      nextReview = nextReview.add(Duration(days: nextReviewDays));

      updatedActiveRecallModel = updatedActiveRecallModel.copyWith(
          nextReview: Timestamp.fromDate(nextReview));

      logger.d(
          "Next review will be ${DateFormat("EEE, dd MMM yyyy").format(nextReview)}");

      await CustomDialog.show(context,
          title: "Feedback about your session",
          subTitle: feedback,
          buttons: [CustomDialogButton(text: "Okay")]);

      await AndroidFlutterLocalNotificationsPlugin()
          .requestExactAlarmsPermission();

      await ref.read(localNotificationProvider).zonedSchedule(
          DateTime.now().millisecondsSinceEpoch % 100000,
          'Active Recall',
          'Time to take your quiz with ${updatedActiveRecallModel.sessionName}',
          nextReview,
          payload: json.encode(updatedActiveRecallModel.toJson()),
          const NotificationDetails(
              android: AndroidNotificationDetails(
            'quiz_notification',
            'Quiz Notification',
            channelDescription:
                'Notifications about spaced repetition quizzes.',
          )),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

      EasyLoading.show(
          status: 'Syncing...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      var failureOrNull = await ref
          .read(activeRecallProvider.notifier)
          .updateFirestoreModel(updatedActiveRecallModel);

      EasyLoading.dismiss();

      if (failureOrNull is Failure) {
        logger.e('Failed to sync: ${failureOrSuccessMessage.message}');
        EasyLoading.showError("Sync failed, try again later.");
      }
    }
  }
}
