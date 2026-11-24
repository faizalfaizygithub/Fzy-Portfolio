import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key, this.icon, this.accent});

  final String label;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.highlight;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.button,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 12.5,
                color: AppColors.textPrimary.withValues(alpha: 0.88),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
