import 'package:flutter/material.dart';

/// Tokens de COR — tema PREMIUM (navy profundo + dourado), fiel ao
/// TEMPLATE-PREMIUM. Nenhuma tela usa cor "solta"; sempre referenciar daqui.
class AppColors {
  AppColors._();

  // Fundo
  static const bg = Color(0xFF061426); // fundo principal
  static const bg2 = Color(0xFF0A1D33); // fundo secundário
  static const surface = Color(0xFF102A43); // cards
  static const surfaceHigh = Color(0xFF153651); // superfície elevada

  // Marca
  static const gold = Color(0xFFFFC02E);
  static const goldDark = Color(0xFFE9A91A);

  // Texto
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB9C9D9);

  // Bordas
  static const border = Color(0xFF294660);

  /// Pílula dourada translúcida (badge "FRASE DO DIA").
  static Color get goldPill => gold.withValues(alpha: 0.16);

  /// Sobreposição branca em elementos sobre foto/gradiente.
  static Color get onPhotoSurface => Colors.white.withValues(alpha: 0.14);

  // ---- Tema CLARO (para o ajuste de Tema em Configurações) ----
  static const lBg = Color(0xFFF2F6FC);
  static const lBg2 = Color(0xFFE9F0F9);
  static const lSurface = Color(0xFFFFFFFF);
  static const lSurfaceHigh = Color(0xFFF7FAFE);
  static const lTextPrimary = Color(0xFF0B1A2E);
  static const lTextSecondary = Color(0xFF5B6B80);
  static const lBorder = Color(0xFFE1E8F2);
}

/// Cores sensíveis ao TEMA (claro/escuro). As telas de "chrome" (fundos,
/// cartões sólidos, textos, nav) usam estas; as telas sobre FOTO usam branco
/// sobre scrim (iguais nos dois temas). O dourado é o mesmo sempre.
class Palette {
  const Palette({
    required this.bg,
    required this.bg2,
    required this.surface,
    required this.surfaceHigh,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  final Color bg;
  final Color bg2;
  final Color surface;
  final Color surfaceHigh;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  static const _dark = Palette(
    bg: AppColors.bg,
    bg2: AppColors.bg2,
    surface: AppColors.surface,
    surfaceHigh: AppColors.surfaceHigh,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
  );

  static const _light = Palette(
    bg: AppColors.lBg,
    bg2: AppColors.lBg2,
    surface: AppColors.lSurface,
    surfaceHigh: AppColors.lSurfaceHigh,
    textPrimary: AppColors.lTextPrimary,
    textSecondary: AppColors.lTextSecondary,
    border: AppColors.lBorder,
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}
