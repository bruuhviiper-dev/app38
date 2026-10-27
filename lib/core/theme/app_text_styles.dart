import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de TIPOGRAFIA.
/// - Interface: Plus Jakarta Sans (500/700/800)
/// - Frases (quotes): Playfair Display — serifa elegante "premium".
///
/// Estilos sem cor de propósito: a cor vem do tema ou de `.copyWith(color:)`.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _ui(double size, FontWeight w,
          {double? height, double? spacing}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: w,
        height: height,
        letterSpacing: spacing,
      );

  // Interface
  static TextStyle get appTitle => _ui(20, FontWeight.w800, height: 1.1);
  static TextStyle get appSubtitle => _ui(12.5, FontWeight.w500, height: 1.2);
  static TextStyle get sectionTitle => _ui(18, FontWeight.w700, height: 1.15);
  static TextStyle get action =>
      _ui(12.5, FontWeight.w700, spacing: 0.2); // "Ver todas"
  static TextStyle get categoryName => _ui(15, FontWeight.w700, height: 1.1);
  static TextStyle get categoryDesc => _ui(11.5, FontWeight.w500, height: 1.25);
  static TextStyle get overline =>
      _ui(11, FontWeight.w800, spacing: 1.1); // "FRASE DO DIA"
  static TextStyle get button => _ui(14.5, FontWeight.w700);
  static TextStyle get body => _ui(14, FontWeight.w500, height: 1.4);
  static TextStyle get navActive => _ui(11, FontWeight.w700);
  static TextStyle get navInactive => _ui(11, FontWeight.w600);
  static TextStyle get caption => _ui(12, FontWeight.w600);

  // Quotes (serifa premium)
  static TextStyle get heroQuote => GoogleFonts.playfairDisplay(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        height: 1.32,
      );
  static TextStyle get inspQuote => GoogleFonts.playfairDisplay(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );
}
