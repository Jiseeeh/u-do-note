import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../details_content.dart';

class FeynmanTechniqueDetails extends ConsumerWidget {
  const FeynmanTechniqueDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(
          height: 16,
        ),
        Image.asset(
          'assets/images/feynman.png',
          width: MediaQuery.sizeOf(context).width,
          height: 230,
          fit: BoxFit.cover,
        ),
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('feynman_desc')),
                const SizedBox(
                  height: 10,
                ),
                DetailsContent(
                  title: context.tr("review_grading_q"),
                  content: context.tr("review_grading"),
                ),
                DetailsContent(
                  title: context.tr("review_quiz_q"),
                  content: context.tr("feynman_quiz"),
                ),
                DetailsContent(
                  title: context.tr("feynman_new_session_q"),
                  content: context.tr("feynman_new_session"),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
