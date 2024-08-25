import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/presentation/providers/acronym/acronym_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/quiz_body.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class AcronymQuizScreen extends ConsumerStatefulWidget {
  final AcronymModel acronymModel;

  const AcronymQuizScreen({required this.acronymModel, Key? key})
      : super(key: key);

  @override
  ConsumerState<AcronymQuizScreen> createState() => _AcronymQuizScreenState();
}

class _AcronymQuizScreenState extends ConsumerState<AcronymQuizScreen> {
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

    if (widget
            .acronymModel.questions![currentQuestionIndex].correctAnswerIndex ==
        selectedAnswerIndex) {
      logger.d('Correct Answer');

      setState(() {
        score++;
      });
    }

    logger.d('Incorrect Answer');

    if (currentQuestionIndex < widget.acronymModel.questions!.length - 1) {
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

        if (widget.acronymModel.questions![currentQuestionIndex]
                .correctAnswerIndex ==
            selectedAnswerIndex) {
          score++;
        }
      }

      timer.cancel();

      var reviewState = ref.read(reviewScreenProvider);

      var acronymModel = widget.acronymModel.copyWith(
          sessionName: reviewState.getSessionTitle,
          createdAt: Timestamp.now(),
          score: score,
          selectedAnswersIndex: selectedAnswersIndex);

      EasyLoading.show(
          status: 'Saving quiz results...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      var res = await ref.read(acronymProvider.notifier).saveQuizResults(
          notebookId: reviewState.getNotebookId, acronymModel: acronymModel);

      EasyLoading.dismiss();

      if (!context.mounted) return;

      if (res is Failure) {
        logger.e('Failed to save quiz results: ${res.message}');
        EasyLoading.showError(context.tr("save_quiz_e"));
      }

      context.router.replace(QuizResultsRoute(
          questions: widget.acronymModel.questions!
              .map((question) => question.toEntity())
              .toList(),
          correctAnswersIndex: widget.acronymModel.questions!
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
        questions: widget.acronymModel.questions!,
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
