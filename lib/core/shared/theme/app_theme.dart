import 'package:flutter/material.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/theme/text_styles.dart';
import 'package:u_do_note/core/shared/theme/text_theme.dart';

class AppTheme {
  /// Light theme data of the app
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: AppTextStyles.fontFamily,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      textTheme: TextThemes.primaryTextTheme,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.secondaryBackground,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.darkSecondaryText),
      // searchBarTheme: SearchBarThemeData(
      //   backgroundColor: MaterialStateColor.resolveWith((_) {
      //     return const Color.fromARGB(255, 255, 255, 255);
      //   }),
      // ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      cardColor: AppColors.secondaryBackground,
    );
  }

  /// Dark theme data of the app
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      primaryColor: AppColors.darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkPrimaryBackground,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSecondaryBackground,
          selectedItemColor: AppColors.darkPrimary,
          unselectedItemColor: AppColors.secondaryText),
      // searchBarTheme: SearchBarThemeData(
      //   backgroundColor: MaterialStateColor.resolveWith((_) {
      //     return AppColors.darkSearchBar;
      //   }),
      // ),
      textTheme: TextThemes.darkTextTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        titleTextStyle: AppTextStyles.h2,
      ),
      cardColor: AppColors.darkSecondaryBackground,
    );
  }
}
