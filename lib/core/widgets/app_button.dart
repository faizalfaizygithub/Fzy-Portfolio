import 'package:flutter/material.dart';

import '../../shared/animations/hover_builder.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

enum AppButtonVariant { primary, outline, ghost }

/// Pill button: label on the left, an icon in a contrasting circle on the
/// right. On hover the icon spins a quarter turn and the label nudges over.
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
    final enabled = onPressed != null && !loading;
    final height = compact ? 44.0 : 52.0;
    final circle = height - 12;

    return HoverBuilder(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      builder: (context, hovered) {
        final active = hovered && enabled;
        final isPrimary = variant == AppButtonVariant.primary;
        final fg = isPrimary ? AppColors.textInverse : AppColors.textPrimary;

        final textStyle = Theme.of(context).textTheme.labelLarge!
            .copyWith(fontSize: compact ? 14 : 15, color: fg);

        final decoration = BoxDecoration(
          color: switch (variant) {
            AppButtonVariant.primary =>
              active ? AppColors.paper : AppColors.cream,
            AppButtonVariant.outline =>
              active ? AppColors.raised : Colors.transparent,
            AppButtonVariant.ghost =>
              active ? AppColors.raised : Colors.transparent,
          },
          borderRadius: AppRadius.button,
          border: variant == AppButtonVariant.outline
              ? Border.all(
                  color: active
                      ? AppColors.textSecondary
                      : AppColors.borderStrong,
                )
              : null,
        );

        final hasIcon = icon != null || loading;
        final iconCircle = AnimatedContainer(
          duration: AppDurations.fast,
          width: circle,
          height: circle,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary ? AppColors.background : AppColors.cream,
          ),
          alignment: Alignment.center,
          child: loading
              ? SizedBox.square(
                  dimension: circle * 0.42,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPrimary
                        ? AppColors.textPrimary
                        : AppColors.textInverse,
                  ),
                )
              : AnimatedRotation(
                  duration: AppDurations.medium,
                  curve: AppCurves.spring,
                  turns: active ? 0.125 : 0,
                  child: Icon(
                    icon,
                    size: compact ? 16 : 18,
                    color: isPrimary
                        ? AppColors.textPrimary
                        : AppColors.textInverse,
                  ),
                ),
        );

        return AnimatedOpacity(
          duration: AppDurations.fast,
          opacity: enabled || loading ? 1 : 0.5,
          child: AnimatedScale(
            duration: AppDurations.fast,
            scale: active ? 1.02 : 1,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppCurves.smooth,
              height: height,
              padding: EdgeInsets.only(
                left: compact ? AppSpacing.md + 2 : AppSpacing.lg,
                right: hasIcon
                    ? 6
                    : (compact ? AppSpacing.md + 2 : AppSpacing.lg),
              ),
              decoration: decoration,
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: expand
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: AnimatedPadding(
                      duration: AppDurations.medium,
                      curve: AppCurves.out,
                      padding: EdgeInsets.only(left: active ? 4 : 0),
                      child: Text(
                        label,
                        style: textStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (hasIcon) ...[
                    SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
                    iconCircle,
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
