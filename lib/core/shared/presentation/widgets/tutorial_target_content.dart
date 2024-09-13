import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';

class TutorialTargetContent extends ConsumerWidget {
  final String translationKey;

  const TutorialTargetContent({required this.translationKey, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ? Make flexible if ever needed
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(translationKey),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.primaryBackground,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp))
      ],
    );
  }
}
