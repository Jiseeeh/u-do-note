import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeitnerSystemNotice extends ConsumerWidget {
  const LeitnerSystemNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            '\u2022 You will be graded based on your response time for every flashcards.Note that the moment the app finished generating flashcards, the timer will start.',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 10),
          Text(
            'What will happen to the flashcards when I start a new session?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            '\u2022 U Do Note will generate flashcards again only if you don\'t have any flashcards that needs to be reviewed again.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
