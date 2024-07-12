import 'package:easy_localization/easy_localization.dart';
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
            '\u2022 ${context.tr("review_desc")}',
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
              title: context.tr("review_grading"),
              content: context.tr("feynman_grading")),
          buildNoticeContent(context,
              title: context.tr("review_quiz_q"),
              content: context.tr("feynman_quiz")),
          buildNoticeContent(context,
              title: context.tr("feynman_new_session_q"),
              content: context.tr("feynman_new_session")),
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
