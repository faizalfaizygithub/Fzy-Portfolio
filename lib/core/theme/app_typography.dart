import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Font roles:
/// * Space Grotesk – headings and display text.
/// * Inter – body copy.
/// * Manrope – labels, buttons and secondary UI text.
/// * JetBrains Mono – code accents (section indices, snippets).
abstract final class AppTypography {
  /// Tests switch this off so no font is fetched over the network.
  static bool useGoogleFonts = true;

  static TextStyle _font(String family, TextStyle style) {
    if (!useGoogleFonts) return style.copyWith(fontFamily: family);
    return switch (family) {
      'Space Grotesk' => GoogleFonts.spaceGrotesk(textStyle: style),
      'Manrope' => GoogleFonts.manrope(textStyle: style),
      'JetBrains Mono' => GoogleFonts.jetBrainsMono(textStyle: style),
      _ => GoogleFonts.inter(textStyle: style),
    };
  }

  static TextStyle heading(TextStyle style) => _font('Space Grotesk', style);
  static TextStyle body(TextStyle style) => _font('Inter', style);
  static TextStyle label(TextStyle style) => _font('Manrope', style);
  static TextStyle mono(TextStyle style) => _font('JetBrains Mono', style);

  static TextTheme textTheme() {
    const primary = AppColors.textPrimary;
    const secondary = AppColors.textSecondary;
    return TextTheme(
      displayLarge: heading(const TextStyle(
        fontSize: 76,
        height: 1.02,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.4,
        color: primary,
      )),
      displayMedium: heading(const TextStyle(
        fontSize: 56,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.6,
        color: primary,
      )),
      displaySmall: heading(const TextStyle(
        fontSize: 44,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: primary,
      )),
      headlineMedium: heading(const TextStyle(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: primary,
      )),
      headlineSmall: heading(const TextStyle(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: primary,
      )),
      titleLarge: heading(const TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: primary,
      )),
      titleMedium: label(const TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w700,
        color: primary,
      )),
      titleSmall: label(const TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w700,
        color: primary,
      )),
      bodyLarge: body(const TextStyle(
        fontSize: 18,
        height: 1.7,
        color: secondary,
      )),
      bodyMedium: body(const TextStyle(
        fontSize: 15,
        height: 1.65,
        color: secondary,
      )),
      bodySmall: body(const TextStyle(
        fontSize: 13,
        height: 1.55,
        color: secondary,
      )),
      labelLarge: label(const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: primary,
      )),
      labelMedium: label(const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: secondary,
      )),
      labelSmall: mono(const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
        color: AppColors.highlight,
      )),
    );
  }
}
