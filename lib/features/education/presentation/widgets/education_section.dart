import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/glow_card.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/animations/reveal.dart';

class _Education {
  const _Education(this.icon, this.title, this.institution, this.location);
  final IconData icon;
  final String title;
  final String institution;
  final String? location;
}

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  static const _items = [
    _Education(Icons.flutter_dash_rounded, 'Diploma in Flutter Development', 'Avodha Edutech', 'Ernakulam'),
    _Education(Icons.school_rounded, 'Bachelor of Commerce (B.Com)', 'Bharathiar University', null),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = !context.isMobile;
    final cards = [
      for (var i = 0; i < _items.length; i++)
        Reveal.staggered(index: i, child: _EducationCard(item: _items[i])),
    ];

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(index: '06', eyebrow: 'Education', title: 'Education'),
          const SizedBox(height: AppSpacing.xl),
          if (wide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: cards[1]),
                ],
              ),
            )
          else ...[
            cards[0],
            const SizedBox(height: AppSpacing.md),
            cards[1],
          ],
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.item});

  final _Education item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: const SizedBox.shrink(),
      builder: (context, hovered, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: AppDurations.medium,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: hovered ? AppColors.brandGradient : null,
              color: hovered ? null : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, color: hovered ? AppColors.textPrimary : AppColors.highlight, size: 26),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: theme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(item.institution, style: theme.titleSmall?.copyWith(color: AppColors.highlight)),
                if (item.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(child: Text(item.location!, style: theme.bodySmall)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
