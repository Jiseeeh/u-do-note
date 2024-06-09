import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';
import 'package:u_do_note/features/review_page/domain/entities/question.dart';
import 'package:u_do_note/features/review_page/presentation/providers/feynman_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class QuizScreen extends ConsumerStatefulWidget {
  final FeynmanModel feynmanModel;
  // ? used when the user reviews an old session and started a new quiz
  final String? newSessionName;
  // ? used when the user opens an old session that on quiz has been taken
  final bool? isFromSessionWithoutQuiz;
  const QuizScreen(
      {this.newSessionName,
      required this.feynmanModel,
      this.isFromSessionWithoutQuiz = false,
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
  late List<QuestionModel> questions;

  @override
  void initState() {
    super.initState();

    questions = widget.feynmanModel.questions!;

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

    if (questions[currentQuestionIndex].correctAnswerIndex ==
        selectedAnswerIndex) {
      logger.d('Correct Answer');

      setState(() {
        score++;
      });
    }

    logger.d('Incorrect Answer');

    if (currentQuestionIndex < questions.length - 1) {
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

        if (questions[currentQuestionIndex].correctAnswerIndex ==
            selectedAnswerIndex) {
          score++;
        }
      }

      timer.cancel();

      // ? save the quiz results
      EasyLoading.show(
          status: 'Saving quiz results...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      var updatedFeynmanModel = widget.feynmanModel
          .copyWith(score: score, selectedAnswersIndex: selectedAnswersIndex);

      var res = await ref
          .read(feynmanTechniqueProvider.notifier)
          .saveQuizResults(
              feynmanModel: updatedFeynmanModel,
              notebookId: ref.read(reviewScreenProvider).notebookId!,
              isFromOldSessionWithoutQuiz: widget.isFromSessionWithoutQuiz!,
              newSessionName: widget.newSessionName);

      EasyLoading.dismiss();

      if (res is Failure) {
        EasyLoading.showError(res.message);
        return;
      }

      if (!context.mounted) return;

      context.router.replace(QuizResultsRoute(
          questions: questions.map((question) => question.toEntity()).toList(),
          correctAnswersIndex:
              questions.map((question) => question.correctAnswerIndex).toList(),
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
                  'Question ${currentQuestionIndex + 1} of ${questions.length}',
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
                questions[currentQuestionIndex].question,
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
                      itemCount: questions[currentQuestionIndex].choices.length,
                      itemBuilder: (context, index) {
                        return AnswerContainer(
                            currentIndex: index,
                            selectedAnswerIndex: selectedAnswerIndex,
                            question:
                                questions[currentQuestionIndex].toEntity(),
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
                                  ? _onFinish(context)
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
