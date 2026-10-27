import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Tema PREMIUM (sempre escuro — navy + dourado), fiel ao TEMPLATE-PREMIUM.
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final bg = isDark ? AppColors.bg : AppColors.lBg;
    final onBg = isDark ? AppColors.textPrimary : AppColors.lTextPrimary;
    final border = isDark ? AppColors.border : AppColors.lBorder;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: b,
    ).copyWith(
      surface: bg,
      primary: AppColors.gold,
      onPrimary: AppColors.bg,
      secondary: AppColors.gold,
      outline: border,
    );

    final text = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: b).textTheme,
    ).apply(bodyColor: onBg, displayColor: onBg);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme,
      textTheme: text,
      splashColor: AppColors.gold.withValues(alpha: 0.08),
      highlightColor: AppColors.gold.withValues(alpha: 0.06),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bg,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.button)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBg,
          backgroundColor: (isDark ? AppColors.surfaceHigh : AppColors.lSurface)
              .withValues(alpha: isDark ? 0.6 : 1.0),
          minimumSize: const Size(0, 50),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.button)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? AppColors.surfaceHigh : AppColors.lTextPrimary,
        contentTextStyle: GoogleFonts.plusJakartaSans(
            color: isDark ? AppColors.textPrimary : Colors.white,
            fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.chip)),
      ),
    );
  }
}
