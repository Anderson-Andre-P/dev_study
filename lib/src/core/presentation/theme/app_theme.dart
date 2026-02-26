import 'package:flutter/material.dart';
import 'app_text_theme.dart';
import 'app_theme_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: AppThemeColors.background,
    textTheme: AppTextTheme.textTheme,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppThemeColors.surface,
      foregroundColor: AppThemeColors.textPrimary,
      centerTitle: false,
    ),
    dividerColor: AppThemeColors.divider,
  );
}
