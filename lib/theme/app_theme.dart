import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32); // Green
  static const secondary = Color(0xFFFB8C00); // Orange
  static const bg = Color(0xFFF6F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1B1D1F);
  static const textSecondary = Color(0xFF5F6B7A);
}

ThemeData buildAppTheme({bool dark = false}) {
  final base = ThemeData(brightness: dark ? Brightness.dark : Brightness.light, useMaterial3: true);
  final colorScheme = dark
      ? ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark)
      : ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light);
  final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );
  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: dark ? colorScheme.background : AppColors.bg,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? colorScheme.surface : AppColors.surface,
      foregroundColor: dark ? colorScheme.onSurface : AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(color: dark ? colorScheme.surface : AppColors.surface, elevation: 0, margin: EdgeInsets.zero),
    dividerColor: AppColors.textSecondary.withOpacity(0.12),
  );
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}