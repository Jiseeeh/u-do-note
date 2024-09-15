import 'package:flutter/material.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/theme/text_styles.dart';
import 'package:u_do_note/core/shared/theme/text_theme.dart';

class AppTheme {
  /// Light theme data of the app
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      textTheme: TextThemes.primaryTextTheme,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      cardColor: AppColors.secondaryBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: MaterialStateColor.resolveWith((_) {
          return AppColors.secondaryBackground;
        }),
        hintStyle: MaterialStateProperty.all(
            const TextStyle(color: AppColors.secondaryText)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.secondaryBackground,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.darkSecondaryText),
    );
  }

  /// Dark theme data of the app
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      textTheme: TextThemes.darkTextTheme,
      scaffoldBackgroundColor: AppColors.darkPrimaryBackground,
      cardColor: AppColors.darkSecondaryBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        titleTextStyle: AppTextStyles.h2,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: MaterialStateColor.resolveWith((_) {
          return AppColors.darkSecondaryBackground;
        }),
        hintStyle: MaterialStateProperty.all(
            const TextStyle(color: AppColors.darkSecondaryText)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSecondaryBackground,
          selectedItemColor: AppColors.darkPrimary,
          unselectedItemColor: AppColors.secondaryText),
    );
  }
}
