import 'package:flutter/material.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/theme/text_styles.dart';

class TextThemes {
  /// Main text theme
  static TextTheme get textTheme {
    return const TextTheme(
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.body,
      titleMedium: AppTextStyles.bodySm,
      titleSmall: AppTextStyles.bodyXs,
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      headlineLarge: AppTextStyles.h2,
      headlineMedium: AppTextStyles.h4,
      headlineSmall: AppTextStyles.h5,
    );
  }

 /// Primary text theme
  static TextTheme get primaryTextTheme {
    return TextTheme(
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.secondaryText),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
      titleMedium: AppTextStyles.bodySm.copyWith(color: AppColors.primaryText),
      titleSmall: AppTextStyles.bodyXs.copyWith(color: AppColors.primaryText),
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.primaryText),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.primaryText),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.primaryText),
      headlineLarge: AppTextStyles.h4.copyWith(color: AppColors.headlineText),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.headlineText),
      headlineSmall: AppTextStyles.h5.copyWith(color: AppColors.headlineText),
    );
  }

  /// Dark text theme
  static TextTheme get darkTextTheme {
    return TextTheme(
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.darkSecondaryText),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.darkSecondaryText),
      titleMedium: AppTextStyles.bodySm.copyWith(color: AppColors.darkPrimaryText),
      titleSmall: AppTextStyles.bodyXs.copyWith(color: AppColors.darkPrimaryText),
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.darkPrimaryText),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.darkPrimaryText),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.darkPrimaryText),
      headlineLarge: AppTextStyles.h4.copyWith(color: AppColors.darkHeadlineText),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.darkHeadlineText),
      headlineSmall: AppTextStyles.h5.copyWith(color: AppColors.darkHeadlineText),
    );
  }

 
}
