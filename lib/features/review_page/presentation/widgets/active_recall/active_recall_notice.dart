import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/features/review_page/data/models/active_recall.dart';

class ActiveRecallNotice extends ConsumerWidget {
  const ActiveRecallNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Column(
        children: [
          Text(
            context.tr("pre_review_notice",
                namedArgs: {"reviewMethod": ActiveRecallModel.name}),
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
              content: context.tr(
                  "You'll take the first quiz 2 hours after starting a session and answering 'What do you remember?' Subsequent quizzes will adjust based on your scores but will continue to ask the same question.")),
          buildNoticeContent(context,
              title: context.tr("How do I know when it is the time of quiz?"),
              content: context.tr(
                  "You'll see your session at on-going reviews in the homepage and receive a notification.")),
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
