import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/domain/entities/question.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class QuizResultsScreen extends ConsumerWidget {
  final List<QuestionEntity> questions;
  final List<int> correctAnswersIndex;
  final List<int> selectedAnswersIndex;

  const QuizResultsScreen(
      {required this.questions,
      required this.correctAnswersIndex,
      required this.selectedAnswersIndex,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var score = 0;
    // ? I think this is fine since this widget will not be rebuilt too many times
    // ? and the questions are ranging from 5 to 10 only...
    for (var (idx, selectedAnswerIndex) in selectedAnswersIndex.indexed) {
      if (correctAnswersIndex[idx] == selectedAnswerIndex) {
        score++;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        var pomodoro = ref.read(pomodoroProvider);

        pomodoro.resetState();

        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var willProceed = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Notice'),
                    content:
                        const Text('Are you done with reviewing the results?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          child: const Text('No')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);

                            var pomodoro = ref.read(pomodoroProvider);

                            pomodoro.resetState();
                          },
                          child: const Text('Yes'))
                    ],
                  );
                });

            if (!willProceed || !context.mounted) return;

            // ? This is to prevent the tutorial from playing in the review screen
            ref.read(reviewScreenProvider).resetState();
            ref.read(pomodoroProvider).resetState();

            context.router.replace(const HomepageRoute());
          },
          child: const Icon(Icons.arrow_forward_rounded),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            SizedBox(
                height: 32,
                width: double.infinity,
                child: Text('Score: $score/${questions.length}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold))),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Text(questions[index].question,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      ListView.builder(
                        itemCount: questions[index].choices.length,
                        primary: false,
                        shrinkWrap: true,
                        itemBuilder: (context, choiceIndex) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: choiceIndex ==
                                                correctAnswersIndex[index]
                                            ? Colors.green
                                            : choiceIndex ==
                                                    selectedAnswersIndex[index]
                                                ? Colors.red
                                                : AppColors.lightShadow),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        questions[index].choices[choiceIndex],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                    choiceIndex == correctAnswersIndex[index]
                                        ? buildCorrectIcon()
                                        : choiceIndex ==
                                                selectedAnswersIndex[index]
                                            ? buildIncorrectIcon()
                                            : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget buildCorrectIcon() => const CircleAvatar(
        backgroundColor: Colors.green,
        radius: 12,
        child: Icon(
          Icons.check,
          color: AppColors.white,
        ),
      );

  Widget buildIncorrectIcon() => const CircleAvatar(
        backgroundColor: Colors.red,
        radius: 12,
        child: Icon(
          Icons.close,
          color: AppColors.white,
        ),
      );
}
