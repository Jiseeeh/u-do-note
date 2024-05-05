import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/domain/entities/question.dart';

@RoutePage()
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  var questions = [
    Question(
        question: 'What is the capital of France?',
        choices: ['Paris', 'London', 'Berlin', 'Madrid'],
        correctAnswerIndex: 0),
    Question(
        question: 'What are the colors of the Nigerian flag?',
        choices: [
          'Red, White, Green',
          'Red, Blue, White',
          'Green, White, Green',
          'Red, White, Blue'
        ],
        correctAnswerIndex: 0),
    Question(
        question: 'What is the capital of Nigeria?',
        choices: ['Paris', 'London', 'Berlin', 'Abuja'],
        correctAnswerIndex: 3),
    Question(
        question: 'How long eagles live?',
        choices: ['10 years', '20 years', '30 years', '40 years'],
        correctAnswerIndex: 2),
    Question(
        question: "Who made flutter?",
        choices: ['Google', 'Facebook', 'Twitter', 'Microsoft'],
        correctAnswerIndex: 0)
  ];
  var currentQuestionIndex = 0;
  var score = 0;
  late Timer timer;
  int startTime = 30;
  int? selectedAnswerIndex;

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

        // force next question
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

    logger.w(
        'correct answer index: ${questions[currentQuestionIndex].correctAnswerIndex}, selected answer index: $selectedAnswerIndex');

    if (questions[currentQuestionIndex].correctAnswerIndex ==
        selectedAnswerIndex) {
      logger.d('Correct Answer');

      setState(() {
        score++;
      });
    }

    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
    }

    setState(() {
      startTime = 30;
      selectedAnswerIndex = null;
    });
  }

  void _onFinish() {
    if (selectedAnswerIndex != null) {
      if (questions[currentQuestionIndex].correctAnswerIndex ==
          selectedAnswerIndex) {
        score++;
      }
    }

    timer.cancel();

    logger.d('Score: $score');
  }

  void _onSelectAnswer(int index) {
    setState(() {
      selectedAnswerIndex = index;
    });
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Question ${currentQuestionIndex + 1} of ${questions.length}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.grey,
                ),
          ),
          Text('Time: $startTime seconds left',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
          const Divider(height: 1, color: AppColors.lightShadow, thickness: 1),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(64),
            decoration: BoxDecoration(
              color: AppColors.extraLightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              questions[currentQuestionIndex].question,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: questions[currentQuestionIndex].choices.length,
                      itemBuilder: (context, index) {
                        return AnswerContainer(
                            currentIndex: index,
                            selectedAnswerIndex: selectedAnswerIndex,
                            question: questions[currentQuestionIndex],
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
                          onPressed:
                              currentQuestionIndex == questions.length - 1
                                  ? _onFinish
                                  : _onNext,
                          child: Text(
                            currentQuestionIndex == questions.length - 1
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
  final Question question;
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
                    : AppColors.extraLightGrey,
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
