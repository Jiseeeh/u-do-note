import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/details_content.dart';

class ActiveRecallDetails extends ConsumerWidget {
  const ActiveRecallDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(
          height: 16,
        ),
        Image.asset(
          'assets/images/active_recall.png',
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
                const SizedBox(
                  height: 10,
                ),
                DetailsContent(
                  title: context.tr("what_is",
                      namedArgs: {"reviewMethod": ActiveRecallModel.name}),
                  content: context.tr("active_recall_what"),
                ),
                DetailsContent(
                  title: context.tr("when_good"),
                  content: context.tr("active_recall_when_good"),
                ),
                DetailsContent(
                  title: context.tr("how_it_works"),
                  content: context.tr("active_recall_how"),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
