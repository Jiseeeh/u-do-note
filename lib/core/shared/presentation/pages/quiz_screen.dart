import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';
import 'package:u_do_note/features/review_page/presentation/providers/acronym/acronym_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/active_recall/active_recall_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/blurting/blurting_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/elaboration/elaboration_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/feynman/feynman_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pq4r/pq4r_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/spaced_repetition/spaced_repetition_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/sq3r/sq3r_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/quiz_body.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class QuizScreen extends ConsumerStatefulWidget {
  final List<QuestionModel> questions;
  final Object model;
  final ReviewMethods reviewMethod;

  const QuizScreen(
      {required this.questions,
      required this.model,
      required this.reviewMethod,
      super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
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
          if (currentQuestionIndex + 1 >= widget.questions.length) {
            selectedAnswersIndex.add(-1);
            _onFinish(context)();
            return;
          }

          selectedAnswersIndex.add(-1);

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

      switch (widget.reviewMethod) {
        case ReviewMethods.leitnerSystem:
          // ? method has no quiz
          break;
        case ReviewMethods.feynmanTechnique:
          var feynmanModel = widget.model as FeynmanModel;

          await ref
              .read(feynmanTechniqueProvider.notifier)
              .onQuizFinish(context, feynmanModel, selectedAnswersIndex, score);
          break;
        case ReviewMethods.pomodoroTechnique:
          var pomodoroModel = widget.model as PomodoroModel;

          await ref.read(pomodoroProvider.notifier).onQuizFinish(
              context, pomodoroModel, selectedAnswersIndex, score);
          break;
        case ReviewMethods.elaboration:
          var elaborationModel = widget.model as ElaborationModel;

          await ref.read(elaborationProvider.notifier).onQuizFinish(
              context, elaborationModel, selectedAnswersIndex, score);
          break;
        case ReviewMethods.acronymMnemonics:
          var acronymModel = widget.model as AcronymModel;

          await ref
              .read(acronymProvider.notifier)
              .onQuizFinish(context, acronymModel, selectedAnswersIndex, score);
          break;
        case ReviewMethods.blurting:
          var blurtingModel = widget.model as BlurtingModel;

          await ref.read(blurtingProvider.notifier).onQuizFinish(
              context, blurtingModel, selectedAnswersIndex, score);
          break;
        case ReviewMethods.spacedRepetition:
          var spacedRepetitionModel = widget.model as SpacedRepetitionModel;

          await ref.read(spacedRepetitionProvider.notifier).onQuizFinish(
              context, spacedRepetitionModel, selectedAnswersIndex, score);
          break;
        case ReviewMethods.activeRecall:
          var activeRecallModel = widget.model as ActiveRecallModel;

          await ref.read(activeRecallProvider.notifier).onQuizFinish(
              context, activeRecallModel, selectedAnswersIndex, score);
          break;
        case ReviewMethods.sq3r:
          var sq3rModel = widget.model as Sq3rModel;

          await ref
              .read(sq3rProvider.notifier)
              .onQuizFinish(context, sq3rModel, selectedAnswersIndex, score);
          break;
        case ReviewMethods.pq4r:
          var pq4rModel = widget.model as Pq4rModel;

          await ref
              .read(pq4rProvider.notifier)
              .onQuizFinish(context, pq4rModel, selectedAnswersIndex, score);
          break;
      }

      if (context.mounted) {
        context.router.replace(QuizResultsRoute(
            questions: widget.questions
                .map((question) => question.toEntity())
                .toList(),
            correctAnswersIndex: widget.questions
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
      onPopInvokedWithResult: (didPop, _) {
        timer.cancel();

        ref.read(reviewScreenProvider).resetState();

        context.router.replace(const ReviewRoute());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Quiz',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 20.sp),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: _buildBody(),
      ),
    );
  }
}
