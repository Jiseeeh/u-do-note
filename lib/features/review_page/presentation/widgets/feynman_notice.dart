import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeynmanNotice extends ConsumerWidget {
  const FeynmanNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Column(
        children: [
          Text(
            'Quick Notice for Feynman Technique',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            '\u2022 You will be asked to choose what notebook do you want to use, and what pages of that notebook you want to generate flashcards with.',
            style: Theme.of(context).textTheme.bodyMedium,
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
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How will I be graded with this?',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '\u2022 You will be graded after the session through a quiz.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'What will happen to the sessions when I start a new session?',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '\u2022 The previous session will be saved and you can review it anytime you want and continue where you left off.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
