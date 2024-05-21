import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/leitner_system_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review_method.dart';

part 'review_method_provider.g.dart';

@Riverpod(keepAlive: true)
class ReviewMethodNotifier extends _$ReviewMethodNotifier {
  @override
  List<ReviewMethodEntity> build() {
    return [];
  }

  List<ReviewMethodEntity> getReviewMethods(BuildContext context) {
    List<ReviewMethodEntity> reviewMethods = [
      ReviewMethodEntity(
        title: 'Leitner System',
        description: 'Use flashcards as a tool for learning.',
        imagePath: 'assets/images/flashcard.png',
        onPressed: () async {
          var willContinue = await showDialog(
              context: context,
              builder: (context) => const LeitnerSystemNotice());

          if (willContinue && context.mounted) {
            showDialog(
                context: context,
                builder: (context) =>
                    const PreReviewMethod(ReviewMethods.leitnerSystem));
          }
        },
      ),
      ReviewMethodEntity(
        title: 'Feynman Technique',
        description:
            'Explain a topic that a five (5) year old child can understand.',
        imagePath: 'assets/images/feynman.png',
        onPressed: () async {
          var willContinue = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Column(
                    children: [
                      Text(
                        'Quick Notice for Feynman Technique',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\u2022 You will be asked to choose what notebook do you want to use, and what pages of that notebook you want to generate flashcards with.',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  scrollable: true,
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("SAMPLE")],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                );
              });

          if (!willContinue) {
            return;
          }

          if (context.mounted) {
            // context.router.push(const FeynmanTechniqueRoute());
            showDialog(
                context: context,
                builder: (context) =>
                    const PreReviewMethod(ReviewMethods.feynmanTechnique));
          }
        },
      ),
      ReviewMethodEntity(
        title: 'Pomodoro Technique',
        description: 'Use a timer to break down work into intervals.',
        imagePath: 'assets/images/pomodoro.png',
        onPressed: () {},
      ),
    ];

    return reviewMethods;
  }
}
