import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';

class SocialIcon extends ConsumerWidget {
  final String src;
  // final Function press;
  const SocialIcon({super.key, required this.src});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(
              width: 1, color: AppColors.darkSecondaryText),
          shape: BoxShape.circle),
      child: SvgPicture.asset(
        src,
        height: 30,
        width: 30,
      ),
    );
  }
}