import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/models/score.dart';
import 'package:u_do_note/features/review_page/presentation/providers/active_recall/active_recall_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/quiz_body.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class ActiveRecallQuizScreen extends ConsumerStatefulWidget {
  final ActiveRecallModel activeRecallModel;
  final String recalledInformation;

  const ActiveRecallQuizScreen(
      {required this.activeRecallModel,
      required this.recalledInformation,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<ActiveRecallQuizScreen> createState() =>
      _ActiveRecallQuizScreenState();
}

class _ActiveRecallQuizScreenState
    extends ConsumerState<ActiveRecallQuizScreen> {
  var currentQuestionIndex = 0;
  var score = 0;
  late Timer timer;
  int startTime = 30;
  int? selectedAnswerIndex;
  List<int> selectedAnswersIndex = [];

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);

    timer = Timer.periodic(oneSec, (timer) {
      if (startTime == 0) {
        timer.cancel();

        // ? force next question
        setState(() {
          currentQuestionIndex++;
          startTime = 30;
          startTimer();
        });
      } else {
        setState(() {
          startTime--;
        });
      }
    });
  }

  void _onNext() {
    if (selectedAnswerIndex == null) {
      return;
    }

    if (widget.activeRecallModel.questions![currentQuestionIndex]
            .correctAnswerIndex ==
        selectedAnswerIndex) {
      logger.d('Correct Answer');

      setState(() {
        score++;
      });
    }

    logger.d('Incorrect Answer');

    if (currentQuestionIndex < widget.activeRecallModel.questions!.length - 1) {
      currentQuestionIndex++;
    }

    setState(() {
      selectedAnswersIndex.add(selectedAnswerIndex!);
      startTime = 30;
      selectedAnswerIndex = null;
    });
  }

  VoidCallback _onFinish(BuildContext context) {
    return () async {
      if (selectedAnswerIndex != null) {
        selectedAnswersIndex.add(selectedAnswerIndex!);

        if (widget.activeRecallModel.questions![currentQuestionIndex]
                .correctAnswerIndex ==
            selectedAnswerIndex) {
          score++;
        }
      }

      timer.cancel();

      var activeRecallScore = ScoreModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: Timestamp.now(),
          score: score);

      ActiveRecallModel updatedActiveRecallModel = widget.activeRecallModel;

      if (widget.activeRecallModel.scores != null) {
        var scores = widget.activeRecallModel.scores;

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
        logger.e(
            'Failed to save quiz results: ${failureOrSuccessMessage.message}');
        EasyLoading.showError(context.tr("save_quiz_e"));
      }

      EasyLoading.show(
          status: 'Getting feedback...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      var failureOrJsonStr = await ref
          .read(activeRecallProvider.notifier)
          .getActiveRecallFeedback(
              updatedActiveRecallModel, widget.recalledInformation);

      if (!context.mounted) return;

      EasyLoading.dismiss();

      if (failureOrJsonStr is Failure) {
        logger.e(
            'Failed to get the feedback: ${failureOrSuccessMessage.message}');
        EasyLoading.showError(
            "Something went wrong when getting the feedback.");
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

      if (context.mounted) {
        context.router.replace(QuizResultsRoute(
            questions: widget.activeRecallModel.questions!
                .map((question) => question.toEntity())
                .toList(),
            correctAnswersIndex: widget.activeRecallModel.questions!
                .map((question) => question.correctAnswerIndex)
                .toList(),
            selectedAnswersIndex: selectedAnswersIndex));

        logger.d('Score: $score');
      }
    };
  }

  void _onSelectAnswer(int index) {
    setState(() {
      selectedAnswerIndex = index;
    });
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: QuizBody(
        questions: widget.activeRecallModel.questions!,
        currentQuestionIndex: currentQuestionIndex,
        startTime: startTime,
        selectedAnswerIndex: selectedAnswerIndex,
        onSelectAnswer: _onSelectAnswer,
        onNext: _onNext,
        onFinish: _onFinish,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        timer.cancel();

        ref.read(reviewScreenProvider).resetState();

        context.router.replace(const ReviewRoute());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: _buildBody(),
      ),
    );
  }
}
