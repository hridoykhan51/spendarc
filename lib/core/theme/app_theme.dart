import 'package:flutter/material.dart';
import 'package:finance_app/core/constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandBlue,
        secondary: AppColors.teal,
        tertiary: AppColors.amber,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      useMaterial3: true,
    );
  }
}
