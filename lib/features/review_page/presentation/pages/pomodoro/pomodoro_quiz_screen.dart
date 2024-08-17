import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/quiz_body.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class PomodoroQuizScreen extends ConsumerStatefulWidget {
  final List<QuestionModel> questions;

  const PomodoroQuizScreen({required this.questions, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<PomodoroQuizScreen> {
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

    if (widget.questions[currentQuestionIndex].correctAnswerIndex ==
        selectedAnswerIndex) {
      logger.d('Correct Answer');

      setState(() {
        score++;
      });
    }

    logger.d('Incorrect Answer');

    if (currentQuestionIndex < widget.questions.length - 1) {
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

        if (widget.questions[currentQuestionIndex].correctAnswerIndex ==
            selectedAnswerIndex) {
          score++;
        }
      }

      timer.cancel();

      // TODO: I tried to extract this function only so that this can be reusable
      // but i had problems with ref, it cannot be passed ig. try to do this later

      var reviewScreenState = ref.read(reviewScreenProvider);
      var pomodoro = ref.read(pomodoroProvider);

      var pomodoroModel = PomodoroModel(
          title: reviewScreenState.sessionTitle!,
          focusedMinutes: (pomodoro.pomodoroTime ~/ 60) *
              (pomodoro.pomodoroInSet) *
              (pomodoro.numberOfSets),
          score: score,
          questions: widget.questions,
          selectedAnswersIndex: selectedAnswersIndex,
          createdAt: Timestamp.now());

      EasyLoading.show(
          status: 'Saving quiz results...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      var res = await ref
          .read(pomodoroProvider.notifier)
          .saveQuizResults(reviewScreenState.notebookId!, pomodoroModel);

      EasyLoading.dismiss();

      if (res is Failure) {
        EasyLoading.showError("Something went wrong. Please try again later.");
        return;
      }

      if (!context.mounted) return;

      context.router.replace(QuizResultsRoute(
          questions:
              widget.questions.map((question) => question.toEntity()).toList(),
          correctAnswersIndex: widget.questions
              .map((question) => question.correctAnswerIndex)
              .toList(),
          selectedAnswersIndex: selectedAnswersIndex));

      logger.d('Score: $score');
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
        questions: widget.questions,
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
