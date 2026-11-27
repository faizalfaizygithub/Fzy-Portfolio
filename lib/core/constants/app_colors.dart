import 'package:flutter/material.dart';

/// Brand palette: an editorial, monochrome system — near-black canvas,
/// cream ink and a white hero. Every color used in the UI comes from here.
abstract final class AppColors {
  // Surfaces
  static const background = Color(0xFF0B0B0B);
  static const backgroundAlt = Color(0xFF111111);
  static const card = Color(0xFF1A1A1A);
  static const raised = Color(0xFF1E1E1E);
  static const ember = Color(0xFF262626);
  static const paper = Color(0xFFFFFFFF);
  static const cream = Color(0xFFF5F5F5);

  // Lines
  static const border = Color(0xFF2A2A2A);
  static const borderStrong = Color(0xFF3B3B3B);

  // Ink
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFA3A3A3);
  static const textMuted = Color(0xFF5C5C5C);
  static const textInverse = Color(0xFF0B0B0B);

  /// Accent is cream, like the reference: emphasis comes from contrast,
  /// not hue.
  static const primary = cream;
  static const secondary = Color(0xFFA3A3A3);
  static const highlight = Color(0xFFFFFFFF);

  static const success = Color(0xFF4ADE80);
  static const error = Color(0xFFFF6B5B);

  // Per-project accents used for mockups and detail pages.
  static const healthcare = Color(0xFF5B9BD8); // Ealzo navy blue
  static const commerce = Color(0xFFC8946A); // Furnyshop walnut brown
  static const realtime = Color(0xFF34D399);
  static const social = Color(0xFFF472B6);
  static const washsouq = Color(0xFF4F8DF7);
  static const socialAlt = Color(0xFFFB7185);

  static const brandGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFCFCFCF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Silver sheen for display text.
  static const textGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFBDBDBD), Color(0xFF7A7A7A)],
  );

  /// Soft spotlight used by panels (CTA, capability cards).
  static const panelGlow = RadialGradient(
    center: Alignment(-0.5, -0.6),
    radius: 1.1,
    colors: [
      Color(0xFF363636),
      Color(0xFF202020),
      Color(0xFF151515),
      background,
    ],
    stops: [0, 0.3, 0.5, 0.75],
  );
}
