import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/answer_container.dart';

class QuizBody extends ConsumerWidget {
  final List<QuestionModel> questions;
  final int startTime;
  final int currentQuestionIndex;
  final int? selectedAnswerIndex;
  final Function(int) onSelectAnswer;
  final Function() onNext;
  final Function(BuildContext) onFinish;

  const QuizBody({required this.questions,
    required this.startTime,
    required this.currentQuestionIndex,
    required this.selectedAnswerIndex,
    required this.onSelectAnswer,
    required this.onNext,
    required this.onFinish,
    Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          height: 10.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              LinearPercentIndicator(
                lineHeight: 8,
                percent: startTime / 30,
                barRadius: const Radius.circular(8),
                leading: Icon(Icons.timer, color: Theme.of(context).cardColor),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: Theme.of(context).cardColor,
                progressColor: AppColors.secondary,
              ),
              Divider(
                  height: 1, color: Theme.of(context).cardColor, thickness: 1),
            ],
          ),
        ),
        Container(
          height: 20.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              questions[currentQuestionIndex].question,
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: questions[currentQuestionIndex].choices.length,
                      itemBuilder: (context, index) {
                        return AnswerContainer(
                            currentIndex: index,
                            selectedAnswerIndex: selectedAnswerIndex,
                            question:
                                questions[currentQuestionIndex].toEntity(),
                            onSelectAnswer: onSelectAnswer);
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
                                  ? onFinish(context)
                                  : onNext,
                          child: Text(
                            currentQuestionIndex == questions.length - 1
                                ? 'Finish'
                                : 'Next',
                            style: Theme.of(context).textTheme.titleMedium,
                          )))
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
