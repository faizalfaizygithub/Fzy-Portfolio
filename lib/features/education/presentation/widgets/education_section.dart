import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/reveal.dart';

class _Education {
  const _Education(this.icon, this.title, this.institution, this.location);
  final IconData icon;
  final String title;
  final String institution;
  final String? location;
}

/// "Always learning": education as two editorial rows beside a heading.
class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  static const _items = [
    _Education(
      Icons.flutter_dash_rounded,
      'Diploma in Flutter Development',
      'Avodha Edutech',
      'Ernakulam',
    ),
    _Education(
      Icons.school_rounded,
      'Bachelor of Commerce (B.Com)',
      'Bharathiar University',
      null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = context.isDesktop;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Education', index: '07'),
        const SizedBox(height: AppSpacing.lg),
        Reveal(
          child: Text(
            'Always\nlearning.',
            style: AppTypography.display(fluid(context, 36, 56)),
          ),
        ),
      ],
    );
    final rows = Column(
      children: [
        const HairlineDivider(),
        for (var i = 0; i < _items.length; i++)
          Reveal.staggered(
            index: i,
            child: _Row(index: i, item: _items[i]),
          ),
      ],
    );

    return Section(
      top: 0,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: heading),
                Expanded(flex: 8, child: rows),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading,
                const SizedBox(height: AppSpacing.xl),
                rows,
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.index, required this.item});

  final int index;
  final _Education item;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Text(
                (index + 1).toString().padLeft(2, '0'),
                style: AppTypography.eyebrow(color: AppColors.textMuted),
              ),
            ),
            Expanded(
              child: AnimatedPadding(
                duration: AppDurations.medium,
                curve: AppCurves.out,
                padding: EdgeInsets.only(left: hovered ? 10 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.heading(
                        TextStyle(
                          fontSize: fluid(context, 20, 28),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          height: 1.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [item.institution, ?item.location].join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            AnimatedContainer(
              duration: AppDurations.medium,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hovered ? AppColors.cream : Colors.transparent,
                border: Border.all(
                  color: hovered ? AppColors.cream : AppColors.borderStrong,
                ),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: hovered
                    ? AppColors.textInverse
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
