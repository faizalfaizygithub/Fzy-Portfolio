import 'package:flutter/material.dart';

import '../../shared/animations/hover_builder.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

enum AppButtonVariant { primary, outline, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.compact = false,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool compact;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: compact ? 14 : 15,
        );
    final enabled = onPressed != null && !loading;

    return HoverBuilder(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      builder: (context, hovered) {
        final active = hovered && enabled;
        final isPrimary = variant == AppButtonVariant.primary;

        final decoration = BoxDecoration(
          gradient: isPrimary ? AppColors.brandGradient : null,
          color: switch (variant) {
            AppButtonVariant.primary => null,
            AppButtonVariant.outline => active
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.card.withValues(alpha: 0.4),
            AppButtonVariant.ghost =>
              active ? AppColors.card : Colors.transparent,
          },
          borderRadius: AppRadius.button,
          border: variant == AppButtonVariant.outline
              ? Border.all(
                  color: active ? AppColors.highlight : AppColors.border,
                )
              : null,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: active ? 0.55 : 0.28),
                    blurRadius: active ? 32 : 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        );

        return AnimatedOpacity(
          duration: AppDurations.fast,
          opacity: enabled || loading ? 1 : 0.5,
          child: AnimatedScale(
            duration: AppDurations.fast,
            scale: active ? 1.03 : 1,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppCurves.smooth,
              height: compact ? 42 : 52,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? AppSpacing.md + 2 : AppSpacing.lg + 2,
              ),
              decoration: decoration,
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  else
                    Flexible(
                      child: Text(
                        label,
                        style: textStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (icon != null && !loading) ...[
                    const SizedBox(width: AppSpacing.xs + 2),
                    AnimatedSlide(
                      duration: AppDurations.fast,
                      offset: active ? const Offset(0.2, 0) : Offset.zero,
                      child: Icon(
                        icon,
                        size: compact ? 16 : 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
