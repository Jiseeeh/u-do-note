import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';

class SpacedRepetitionNotice extends ConsumerWidget {
  const SpacedRepetitionNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Column(
        children: [
          Text(
            context.tr("pre_review_notice",
                namedArgs: {"reviewMethod": SpacedRepetitionModel.name}),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            context.tr("review_desc"),
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
              title: context.tr("review_grading_q"),
              content: context.tr("You will be graded every quiz you take.")),
          buildNoticeContent(context,
              title: context.tr("review_quiz_q"),
              content: context.tr("You will take the quiz after the timer runs out, and the next subsequent quizzes will be on intervals")),
          buildNoticeContent(context,
              title: context.tr("How do I know when it is the time of quiz?"),
              content: context.tr(
                  "You'll see your session at on-going reviews in the homepage.")),
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
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
