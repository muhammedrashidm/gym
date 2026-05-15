import 'package:flutter/material.dart';

class AppColors {
  // Slate & Sinew Light Theme Colors
  static const Color primaryLight = Color(0xFF000000);
  static const Color primaryContainerLight = Color(0xFF3C3B3B);
  static const Color secondaryLight = Color(0xFF5F5E5E);
  static const Color secondaryContainerLight = Color(0xFFD6D4D3);
  static const Color tertiaryLight = Color(0xFF3B3B3C);
  static const Color tertiaryContainerLight = Color(0xFF747474);
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color surfaceLight = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowLight = Color(0xFFF3F3F3);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color errorLight = Color(0xFFBA1A1A);
  
  static const Color onPrimaryLight = Color(0xFFE5E2E1);
  static const Color onPrimaryContainerLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF1A1C1C);
  static const Color onSurfaceLight = Color(0xFF1A1C1C);
  static const Color onSurfaceVariantLight = Color(0xFF474747);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  
  static const Color outlineLight = Color(0xFF777777);
  static const Color outlineVariantLight = Color(0xFFC6C6C6);

  // Slate & Sinew Dark Theme Colors
  static const Color primaryDark = Color(0xFFFFFFFF);
  static const Color primaryContainerDark = Color(0xFFE2E2E2);
  static const Color secondaryDark = Color(0xFFC7C6C6);
  static const Color secondaryContainerDark = Color(0xFF484949);
  static const Color tertiaryDark = Color(0xFFFFFFFF);
  static const Color tertiaryContainerDark = Color(0xFFE5E2E1);
  static const Color backgroundDark = Color(0xFF131313);
  static const Color surfaceDark = Color(0xFF131313);
  static const Color surfaceContainerLowDark = Color(0xFF1C1B1B);
  static const Color surfaceContainerLowestDark = Color(0xFF0E0E0E);
  static const Color errorDark = Color(0xFFFFB4AB);
  
  static const Color onPrimaryDark = Color(0xFF2F3131);
  static const Color onPrimaryContainerDark = Color(0xFF636565);
  static const Color onSecondaryDark = Color(0xFF2F3131);
  static const Color onBackgroundDark = Color(0xFFE5E2E1);
  static const Color onSurfaceDark = Color(0xFFE5E2E1);
  static const Color onSurfaceVariantDark = Color(0xFFC4C7C8);
  static const Color onErrorDark = Color(0xFF690005);
  
  static const Color outlineDark = Color(0xFF8E9192);
  static const Color outlineVariantDark = Color(0xFF444748);

  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryLight,
    onPrimary: onPrimaryLight,
    primaryContainer: primaryContainerLight,
    onPrimaryContainer: onPrimaryContainerLight,
    secondary: secondaryLight,
    onSecondary: onSecondaryLight,
    secondaryContainer: secondaryContainerLight,
    tertiary: tertiaryLight,
    onTertiary: const Color(0xFFE3E2E2),
    tertiaryContainer: tertiaryContainerLight,
    error: errorLight,
    onError: onErrorLight,
    surface: surfaceLight,
    onSurface: onSurfaceLight,
    surfaceContainerHighest: const Color(0xFFE2E2E2),
    onSurfaceVariant: onSurfaceVariantLight,
    outline: outlineLight,
    outlineVariant: outlineVariantLight,
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    onPrimary: onPrimaryDark,
    primaryContainer: primaryContainerDark,
    onPrimaryContainer: onPrimaryContainerDark,
    secondary: secondaryDark,
    onSecondary: onSecondaryDark,
    secondaryContainer: secondaryContainerDark,
    tertiary: tertiaryDark,
    onTertiary: const Color(0xFF313030),
    tertiaryContainer: tertiaryContainerDark,
    error: errorDark,
    onError: onErrorDark,
    surface: surfaceDark,
    onSurface: onSurfaceDark,
    surfaceContainerHighest: const Color(0xFF353534),
    onSurfaceVariant: onSurfaceVariantDark,
    outline: outlineDark,
    outlineVariant: outlineVariantDark,
  );
}
