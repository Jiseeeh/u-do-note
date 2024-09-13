import 'package:flutter/material.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/theme/text_styles.dart';

class TextThemes {
  
 /// Primary text theme
  static TextTheme get primaryTextTheme {
    return TextTheme(
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.secondaryText, fontFamily: 'Readex'),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.secondaryText, fontFamily: 'Readex'),
      bodySmall: AppTextStyles.bodySm.copyWith(color: AppColors.secondaryText, fontFamily: 'Readex'),

      headlineLarge: AppTextStyles.h1.copyWith(color: AppColors.primaryText, fontFamily: 'Outfit'),
      headlineMedium: AppTextStyles.h2.copyWith(color: AppColors.primaryText, fontFamily: 'Outfit'),
      headlineSmall: AppTextStyles.h3.copyWith(color: AppColors.primaryText, fontFamily: 'Outfit'),
      
      titleLarge: AppTextStyles.h4.copyWith(color: AppColors.headlineText, fontFamily: 'Outfit'),
      titleMedium: AppTextStyles.h5.copyWith(color: AppColors.headlineText, fontFamily: 'Outfit'),
      titleSmall: AppTextStyles.h6.copyWith(color: AppColors.headlineText, fontFamily: 'Outfit'),
    );
  }

  /// Dark text theme
  static TextTheme get darkTextTheme {
    return TextTheme(
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.darkSecondaryText, fontFamily: 'Readex'),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.darkSecondaryText, fontFamily: 'Readex'),
      bodySmall: AppTextStyles.bodySm.copyWith(color: AppColors.darkSecondaryText, fontFamily: 'Readex'),

      headlineLarge: AppTextStyles.h1.copyWith(color: AppColors.darkPrimaryText, fontFamily: 'Outfit'),
      headlineMedium: AppTextStyles.h2.copyWith(color: AppColors.darkPrimaryText, fontFamily: 'Outfit'),
      headlineSmall: AppTextStyles.h3.copyWith(color: AppColors.darkPrimaryText, fontFamily: 'Outfit'),

      titleLarge: AppTextStyles.h4.copyWith(color: AppColors.darkHeadlineText, fontFamily: 'Outfit'),
      titleMedium: AppTextStyles.h5.copyWith(color: AppColors.darkHeadlineText, fontFamily: 'Outfit'),
      titleSmall: AppTextStyles.h6.copyWith(color: AppColors.darkHeadlineText, fontFamily: 'Outfit'),
    );
  }

 
}
