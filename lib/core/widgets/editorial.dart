import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../responsive/responsive.dart';
import '../theme/app_typography.dart';

/// Fluid value between [min] (at 360px wide) and [max] (at 1440px wide) —
/// the Flutter equivalent of CSS `clamp(min, a + b·vw, max)`.
double fluid(BuildContext context, double min, double max) {
  final w = MediaQuery.sizeOf(context).width;
  final t = ((w - 360) / (1440 - 360)).clamp(0.0, 1.0);
  return min + (max - min) * t;
}

/// Horizontal page gutter, ~20px on phones up to ~68px on wide screens.
double gutter(BuildContext context) => fluid(context, 20, 68);

/// Centred, max-width content area with the page gutter and section rhythm.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.child,
    this.top,
    this.bottom,
    this.color,
    this.maxWidth = AppSizes.maxContentWidth,
  });

  final Widget child;
  final double? top;
  final double? bottom;
  final Color? color;
  final double maxWidth;

  static double rhythm(BuildContext context) =>
      context.responsive<double>(mobile: 88, tablet: 104, desktop: 128);

  @override
  Widget build(BuildContext context) {
    final r = rhythm(context);
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        gutter(context),
        top ?? r,
        gutter(context),
        bottom ?? r,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
    return color == null ? content : ColoredBox(color: color!, child: content);
  }
}

/// `( 02 — EXPERIENCE )` eyebrow label.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.index,
    this.color = AppColors.textSecondary,
  });

  final String text;
  final String? index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = index == null ? text : '$index — $text';
    return Text(
      '( ${label.toUpperCase()} )',
      style: AppTypography.eyebrow(color: color),
    );
  }
}

/// Thin rule that draws itself from left to right.
class HairlineDivider extends StatelessWidget {
  const HairlineDivider({super.key, this.color = AppColors.borderStrong});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(height: 1, color: color);
}

/// Small rounded tag (tech stacks).
class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.inverse = false, this.dense = false});

  final String label;
  final bool inverse;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 14,
        vertical: dense ? 5 : 7,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.button,
        color: inverse ? AppColors.textInverse.withValues(alpha: 0.06) : null,
        border: Border.all(
          color: inverse
              ? AppColors.textInverse.withValues(alpha: 0.18)
              : AppColors.borderStrong,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.label(
          TextStyle(
            fontSize: dense ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: inverse ? AppColors.textInverse : AppColors.textSecondary,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
