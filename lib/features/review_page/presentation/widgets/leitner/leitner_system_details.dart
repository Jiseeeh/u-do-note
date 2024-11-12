import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../details_content.dart';

class LeitnerSystemDetails extends ConsumerWidget {
  const LeitnerSystemDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(
          height: 16,
        ),
        Image.asset(
          'assets/images/instruction_leitner.jpg',
          width: MediaQuery.sizeOf(context).width,
          height: 350,
          fit: BoxFit.fitHeight,
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
                Text(context.tr('leitner_desc')),
                const SizedBox(
                  height: 10,
                ),
                DetailsContent(
                  title: context.tr("review_grading_q"),
                  content: context.tr("leitner_grading"),
                ),
                DetailsContent(
                  title: context.tr("leitner_new_session_q"),
                  content: context.tr("leitner_new_session"),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
