import 'package:flutter/material.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/theme/text_styles.dart';
import 'package:u_do_note/core/shared/theme/text_theme.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.white,
        secondary: AppColors.lightGrey,
        error: AppColors.error,
        background: AppColors.primary,
        tertiary: Color.fromARGB(255, 194, 182, 72),
      ),
      scaffoldBackgroundColor: AppColors.primary,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkBottomNavBar),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: MaterialStateColor.resolveWith((_) {
          return AppColors.darkSearchBar;
        }),
      ),
      textTheme: TextThemes.darkTextTheme,
      primaryTextTheme: TextThemes.primaryTextTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        titleTextStyle: AppTextStyles.h2,
      ),
      cardColor: const Color(0xff11365D),
    );
  }

  /// Light theme data of the app
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: AppTextStyles.fontFamily,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      textTheme: TextThemes.textTheme,
      primaryTextTheme: TextThemes.primaryTextTheme,
      scaffoldBackgroundColor: AppColors.white,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: MaterialStateColor.resolveWith((_) {
          return const Color.fromARGB(255, 255, 255, 255);
        }),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        onSecondary: Color(0xffABACAF),
        tertiary: Color.fromARGB(255, 255, 245, 157),
      ),
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      cardColor: const Color(0xffD2E3FF)
    );
  }
}
