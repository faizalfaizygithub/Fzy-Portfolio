import 'package:flutter/material.dart';

/// Brand palette. Every color used in the UI should come from here.
abstract final class AppColors {
  static const background = Color(0xFF080812);
  static const backgroundAlt = Color(0xFF101020);
  static const card = Color(0xFF151525);
  static const border = Color(0xFF292940);

  static const primary = Color(0xFF9354CB);
  static const secondary = Color(0xFF7547F5);
  static const highlight = Color(0xFFA78BFA);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1B5);
  static const textMuted = Color(0xFF6E6E86);

  static const success = Color(0xFF4ADE80);
  static const error = Color(0xFFF87171);

  // Per-project accents used for mockups and detail pages.
  static const healthcare = Color(0xFF5B9BD8); // Ealzo navy blue
  static const commerce = Color(0xFFC8946A); // Furnyshop walnut brown
  static const realtime = Color(0xFF34D399);
  static const social = Color(0xFFF472B6);
  static const washsouq = Color(0xFF4F8DF7);
  static const socialAlt = Color(0xFFFB7185);

  static const brandGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const textGradient = LinearGradient(
    colors: [highlight, primary, secondary],
  );
}
