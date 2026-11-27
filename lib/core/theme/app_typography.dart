import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Font roles:
/// * Manrope – headings, body and UI (one family keeps the page calm).
/// * Antonio – condensed numerals (indices, counters, the process dial).
/// * Unbounded – the giant footer wordmark.
/// * JetBrains Mono – small `( LABELS )` and dates.
abstract final class AppTypography {
  /// Tests switch this off so no font is fetched over the network.
  static bool useGoogleFonts = true;

  static TextStyle _font(String family, TextStyle style) {
    if (!useGoogleFonts) return style.copyWith(fontFamily: family);
    return switch (family) {
      'Antonio' => GoogleFonts.antonio(textStyle: style),
      'Unbounded' => GoogleFonts.unbounded(textStyle: style),
      'JetBrains Mono' => GoogleFonts.jetBrainsMono(textStyle: style),
      _ => GoogleFonts.manrope(textStyle: style),
    };
  }

  static TextStyle heading(TextStyle style) => _font('Manrope', style);
  static TextStyle body(TextStyle style) => _font('Manrope', style);
  static TextStyle label(TextStyle style) => _font('Manrope', style);
  static TextStyle mono(TextStyle style) => _font('JetBrains Mono', style);
  static TextStyle numeric(TextStyle style) => _font('Antonio', style);
  static TextStyle wordmark(TextStyle style) => _font('Unbounded', style);

  /// Huge display text (hero name, section headlines). Size is fluid.
  static TextStyle display(
    double size, {
    Color color = AppColors.textPrimary,
  }) => heading(
    TextStyle(
      fontSize: size,
      height: 0.95,
      fontWeight: FontWeight.w700,
      letterSpacing: -size * 0.045,
      color: color,
    ),
  );

  /// `( EXPERIENCE )` style labels.
  static TextStyle eyebrow({
    Color color = AppColors.textSecondary,
    double size = 12.5,
  }) => mono(
    TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w500,
      letterSpacing: size * 0.08,
      height: 1.2,
      color: color,
    ),
  );

  static TextTheme textTheme() {
    const primary = AppColors.textPrimary;
    const secondary = AppColors.textSecondary;
    return TextTheme(
      displayLarge: heading(
        const TextStyle(
          fontSize: 76,
          height: 1.0,
          fontWeight: FontWeight.w700,
          letterSpacing: -3.4,
          color: primary,
        ),
      ),
      displayMedium: heading(
        const TextStyle(
          fontSize: 56,
          height: 1.04,
          fontWeight: FontWeight.w700,
          letterSpacing: -2.2,
          color: primary,
        ),
      ),
      displaySmall: heading(
        const TextStyle(
          fontSize: 44,
          height: 1.08,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.4,
          color: primary,
        ),
      ),
      headlineMedium: heading(
        const TextStyle(
          fontSize: 32,
          height: 1.12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.8,
          color: primary,
        ),
      ),
      headlineSmall: heading(
        const TextStyle(
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: primary,
        ),
      ),
      titleLarge: heading(
        const TextStyle(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: primary,
        ),
      ),
      titleMedium: label(
        const TextStyle(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
      titleSmall: label(
        const TextStyle(
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
      bodyLarge: body(
        const TextStyle(fontSize: 18, height: 1.6, color: secondary),
      ),
      bodyMedium: body(
        const TextStyle(fontSize: 15, height: 1.6, color: secondary),
      ),
      bodySmall: body(
        const TextStyle(fontSize: 13, height: 1.5, color: secondary),
      ),
      labelLarge: label(
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: primary,
        ),
      ),
      labelMedium: label(
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: secondary,
        ),
      ),
      labelSmall: mono(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: secondary,
        ),
      ),
    );
  }
}
