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
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/spaced_repetition/spaced_repetition_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/quiz_body.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class SpacedRepetitionQuizScreen extends ConsumerStatefulWidget {
  final SpacedRepetitionModel spacedRepetitionModel;

  const SpacedRepetitionQuizScreen(
      {required this.spacedRepetitionModel, Key? key})
      : super(key: key);

  @override
  ConsumerState<SpacedRepetitionQuizScreen> createState() =>
      _SpacedRepetitionQuizScreenState();
}

class _SpacedRepetitionQuizScreenState
    extends ConsumerState<SpacedRepetitionQuizScreen> {
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

    if (widget.spacedRepetitionModel.questions![currentQuestionIndex]
            .correctAnswerIndex ==
        selectedAnswerIndex) {
      logger.d('Correct Answer');

      setState(() {
        score++;
      });
    }

    logger.d('Incorrect Answer');

    if (currentQuestionIndex <
        widget.spacedRepetitionModel.questions!.length - 1) {
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

        if (widget.spacedRepetitionModel.questions![currentQuestionIndex]
                .correctAnswerIndex ==
            selectedAnswerIndex) {
          score++;
        }
      }

      timer.cancel();

      var spacedRepScore = SpacedRepetitionScore(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: Timestamp.now(),
          score: score);

      SpacedRepetitionModel updatedSpacedRepModel =
          widget.spacedRepetitionModel;

      if (widget.spacedRepetitionModel.scores != null) {
        var scores = widget.spacedRepetitionModel.scores;

        scores!.add(spacedRepScore);

        updatedSpacedRepModel.copyWith(scores: scores);
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

      if (context.mounted) {
        context.router.replace(QuizResultsRoute(
            questions: widget.spacedRepetitionModel.questions!
                .map((question) => question.toEntity())
                .toList(),
            correctAnswersIndex: widget.spacedRepetitionModel.questions!
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
        questions: widget.spacedRepetitionModel.questions!,
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
