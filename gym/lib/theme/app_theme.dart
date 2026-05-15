import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.lightColorScheme,
      textTheme: AppTextTheme.getTextTheme(Brightness.light),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      // Custom component themes can be added here
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Strict 0px shape language
          ),
          backgroundColor: AppColors.primaryLight, // Solid black
          foregroundColor: AppColors.onPrimaryLight, // e5e2e1
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.darkColorScheme,
      textTheme: AppTextTheme.getTextTheme(Brightness.dark),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Strict 0px shape language
          ),
          backgroundColor: AppColors.primaryDark, // Solid white
          foregroundColor: AppColors.onPrimaryDark, // Black text
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
    );
  }
}
