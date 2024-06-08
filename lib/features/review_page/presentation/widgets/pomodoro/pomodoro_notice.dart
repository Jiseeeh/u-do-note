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
            'Quick Notice for the Pomodoro Technique',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            '\u2022 You will be asked to choose what notebook do you want to use, and what pages of that notebook you want to use for the quiz later after the pomodoro session.',
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
          buildNoticeContent(context,
              title: "What does the red and green timer means?",
              content:
                  "The red timer represents the pomodoro session, while the green timer represents the break session."),
          buildNoticeContent(context,
              title: 'How will I be graded with this?',
              content: 'You will be graded after the session through a quiz.'),
          buildNoticeContent(context,
              title: 'How to start the quiz?',
              content:
                  'You will be asked if you want to start the quiz after you finish a pomodoro session.'),
        ],
      ),
    );
  }

  Widget buildNoticeContent(BuildContext context,
      {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '\u2022 $content',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
