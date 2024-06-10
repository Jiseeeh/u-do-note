import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';
import 'package:u_do_note/features/review_page/domain/entities/question.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class QuizScreen extends ConsumerStatefulWidget {
  final List<QuestionModel> questions;
  final Future<void> Function(
          List<int> selectedAnswersIndex, int score)
      onQuizFinish;
  const QuizScreen(
      {
      required this.onQuizFinish,
      required this.questions,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  var currentQuestionIndex = 0;
  var score = 0;
  late Timer timer;
  int startTime = 30;
  int? selectedAnswerIndex;
  List<int> selectedAnswersIndex = [];
  // late List<QuestionModel> questions;

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

      widget.onQuizFinish(selectedAnswersIndex, score);

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
      child: Column(
        children: [
          SizedBox(
            height: 10.h,
            child: Column(
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1} of ${widget.questions.length}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.grey,
                      ),
                ),
                Text('Time: $startTime seconds left',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.grey,
                        )),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: startTime / 30,
                  barRadius: const Radius.circular(8),
                  leading: const Icon(Icons.timer, color: AppColors.grey),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor: AppColors.lightShadow,
                  progressColor: AppColors.secondary,
                ),
                const Divider(
                    height: 1, color: AppColors.lightShadow, thickness: 1),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Container(
            height: 20.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.extraLightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                widget.questions[currentQuestionIndex].question,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.extraLightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          widget.questions[currentQuestionIndex].choices.length,
                      itemBuilder: (context, index) {
                        return AnswerContainer(
                            currentIndex: index,
                            selectedAnswerIndex: selectedAnswerIndex,
                            question: widget.questions[currentQuestionIndex]
                                .toEntity(),
                            onSelectAnswer: _onSelectAnswer);
                      }),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: currentQuestionIndex ==
                                  widget.questions.length - 1
                              ? _onFinish(context)
                              : _onNext,
                          child: Text(
                            currentQuestionIndex == widget.questions.length - 1
                                ? 'Finish'
                                : 'Next',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.white),
                          )))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: _buildBody(),
    );
  }
}

class AnswerContainer extends ConsumerWidget {
  final int currentIndex;
  final int? selectedAnswerIndex;
  final QuestionEntity question;
  final Function(int index) onSelectAnswer;

  const AnswerContainer(
      {required this.currentIndex,
      required this.selectedAnswerIndex,
      required this.question,
      required this.onSelectAnswer,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            onSelectAnswer(currentIndex);
          },
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedAnswerIndex == currentIndex
                    ? AppColors.jetBlack
                    : AppColors.lightShadow,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(question.choices[currentIndex],
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
