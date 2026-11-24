import 'package:flutter/material.dart';

import '../../shared/animations/reveal.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../responsive/responsive.dart';

/// Section heading in the portfolio's "code comment" style:
///
///   // 02 — SKILLS
///   Technologies I Work With
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.index,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.center = false,
  });

  final String index;
  final String eyebrow;
  final String title;
  final String? subtitle;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final titleStyle = context.responsive(
      mobile: theme.headlineMedium!.copyWith(fontSize: 34, height: 1.1),
      tablet: theme.displaySmall,
      desktop: theme.displayMedium,
    );
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = center ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Reveal(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('// $index', style: theme.labelSmall),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 28,
                height: 1,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  eyebrow.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Reveal(
          delay: AppDurations.stagger,
          child: Semantics(
            header: true,
            child: Text(title, style: titleStyle, textAlign: textAlign),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.md),
          Reveal(
            delay: AppDurations.stagger * 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                subtitle!,
                style: theme.bodyLarge,
                textAlign: textAlign,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
