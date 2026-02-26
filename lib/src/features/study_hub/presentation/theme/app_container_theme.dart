import 'package:flutter/material.dart';
import 'app_theme_colors.dart';
import 'app_border_radius.dart';

class AppContainerTheme {
  AppContainerTheme._();

  static BoxDecoration card = BoxDecoration(
    color: AppThemeColors.surface,
    borderRadius: AppBorderRadius.medium,
    border: Border.all(color: AppThemeColors.border),
  );
}
