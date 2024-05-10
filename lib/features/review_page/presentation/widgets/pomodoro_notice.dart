import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PomodoroNotice extends ConsumerWidget {
  const PomodoroNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Column(
        children: [
          Text(
            'Quick Notice for Pomodoro Technique',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            'This technique will help improve productivity by breaking work into manageable intervals, maintaining focus, and preventing burnout.',
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
            'How does Pomodoro Technique works ?',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "\u2022 Set a Timer: Choose a task you want to work on, known as one Pomodoro. \n\u2022 Work: Focus exclusively on the task until the timer sets off. Avoid distractions and interruptions during this time. \n\u2022 Take a Short Break: When the timer goes off, take a short break. Use this time to rest and recharge.\n\u2022 Repeat: After completing four Pomodoros, take a longer break to relax and rejuvenate.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
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
        ],
      ),
    );
  }
}
