import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../animations/hover_builder.dart';

class BackToTopButton extends StatelessWidget {
  const BackToTopButton({super.key, required this.visible, required this.onTap});

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: AppDurations.medium,
        curve: AppCurves.emphasized,
        offset: visible ? Offset.zero : const Offset(0, 0.6),
        child: AnimatedOpacity(
          duration: AppDurations.medium,
          opacity: visible ? 1 : 0,
          child: Tooltip(
            message: 'Back to top',
            child: HoverBuilder(
              onTap: onTap,
              semanticLabel: 'Back to top',
              builder: (context, hovered) => AnimatedContainer(
                duration: AppDurations.fast,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hovered ? AppColors.brandGradient : null,
                  color: hovered ? null : AppColors.card,
                  border: Border.all(
                    color: hovered ? Colors.transparent : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: hovered ? 0.5 : 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: AnimatedSlide(
                  duration: AppDurations.fast,
                  offset: hovered ? const Offset(0, -0.12) : Offset.zero,
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
