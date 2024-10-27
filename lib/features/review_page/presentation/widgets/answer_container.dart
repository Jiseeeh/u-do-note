import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/domain/entities/question.dart';

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
      super.key});

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
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).cardColor,
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
