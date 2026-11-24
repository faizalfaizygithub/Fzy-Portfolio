import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_info.dart';
import '../../core/theme/app_typography.dart';
import '../animations/hover_builder.dart';

/// "MF" monogram followed by a `</mf>` tag, nodding to widget markup.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.onTap, this.size = 40, this.showTag = true});

  final VoidCallback? onTap;
  final double size;

  /// Shows the `</mf>` tag after the monogram.
  final bool showTag;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: '${AppInfo.name}, back to top',
      builder: (context, hovered) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedRotation(
            duration: AppDurations.medium,
            curve: AppCurves.emphasized,
            turns: hovered ? 0.125 : 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(size * 0.3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: hovered ? 0.6 : 0.35),
                    blurRadius: hovered ? 24 : 14,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedRotation(
                duration: AppDurations.medium,
                curve: AppCurves.emphasized,
                turns: hovered ? -0.125 : 0,
                child: Text(
                  AppInfo.initials,
                  style: AppTypography.heading(TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  )),
                ),
              ),
            ),
          ),
          if (showTag) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              '</${AppInfo.initials.toLowerCase()}>',
              style: AppTypography.mono(TextStyle(
                fontSize: 14,
                color: hovered ? AppColors.highlight : AppColors.textSecondary,
              )),
            ),
          ],
        ],
      ),
    );
  }
}
