import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/shared/theme/text_styles.dart';

class Onboard extends ConsumerWidget {
  final String label;
  final String description;
  final bool isLast;

  const Onboard({
    super.key,
    required this.label,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding:
          EdgeInsets.symmetric(horizontal: 40, vertical: isLast ? 15.h : 5.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          Text(description,
              textAlign: TextAlign.center, style: AppTextStyles.bodyLg),
        ],
      ),
    );
  }
}
