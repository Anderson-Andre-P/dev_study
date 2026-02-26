import 'package:flutter/material.dart';
import 'app_theme_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static const textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppThemeColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppThemeColors.textPrimary,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: AppThemeColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: AppThemeColors.textSecondary),
  );
}
