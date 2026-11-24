import 'package:flutter/material.dart';

import '../../shared/animations/hover_builder.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

/// Rounded card with a subtle border that lights up with the brand gradient
/// and lifts slightly on hover.
class GlowCard extends StatelessWidget {
  const GlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.accent = AppColors.primary,
    this.lift = 6,
    this.radius = AppRadius.lg,
    this.semanticLabel,
    this.builder,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color accent;
  final double lift;
  final double radius;
  final String? semanticLabel;

  /// Optional hook to vary the child with hover state.
  final Widget Function(BuildContext context, bool hovered, Widget child)?
      builder;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      semanticLabel: semanticLabel,
      builder: (context, hovered) {
        final inner = builder?.call(context, hovered, child) ?? child;
        return AnimatedContainer(
          duration: AppDurations.medium,
          curve: AppCurves.smooth,
          transform: Matrix4.translationValues(0, hovered ? -lift : 0, 0),
          // Gradient border: outer gradient + inner fill with 1px inset.
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: hovered
                  ? [accent, AppColors.secondary.withValues(alpha: 0.3)]
                  : [AppColors.border, AppColors.border],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: hovered ? 0.22 : 0),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(radius - 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(AppColors.card, accent, hovered ? 0.08 : 0.03)!,
                  AppColors.card,
                ],
              ),
            ),
            child: inner,
          ),
        );
      },
    );
  }
}
