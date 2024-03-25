import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review_method.dart';

part 'review_method_provider.g.dart';

@Riverpod(keepAlive: true)
class ReviewMethodNotifier extends _$ReviewMethodNotifier {
  @override
  List<ReviewMethodEntity> build() {
    // define the review methods
    return [];
  }

  List<ReviewMethodEntity> getReviewMethods(BuildContext context) {
    List<ReviewMethodEntity> reviewMethods = [
      ReviewMethodEntity(
        title: 'Leitner System',
        description: 'Use flashcards as a tool for learning.',
        imagePath: 'lib/assets/flashcard.png',
        onPressed: () async {
          var willContinue = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Column(
                    children: [
                      Text(
                        'Quick Notice for Leitner System',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\u2022 You will be asked to choose what notebook do you want to use, and what pages of that notebook you want to generate flashcards with.',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  scrollable: true,
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
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How will I be graded with this?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '\u2022 You will be graded based on your response time for every flashcards.Note that the moment the app finished generating flashcards, the timer will start.',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'What will happen to the flashcards when I start a new session?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '\u2022 U Do Note will generate flashcards again only if you don\'t have any flashcards that needs to be reviewed again.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              });

          if (!willContinue) {
            return;
          }

          if (context.mounted) {
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
        imagePath: 'lib/assets/feynman.png',
        onPressed: () {},
      ),
      ReviewMethodEntity(
        title: 'Pomodoro Technique',
        description: 'Use a timer to break down work into intervals.',
        imagePath: 'lib/assets/pomodoro.png',
        onPressed: () {},
      ),
    ];

    return reviewMethods;
  }
}
