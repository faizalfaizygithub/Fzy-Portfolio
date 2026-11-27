import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/line_reveal.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../../shared/models/skill.dart';
import '../../data/skills_data.dart';

class _Discipline {
  const _Discipline(this.title, this.categories);
  final String title;
  final List<String> categories;
}

/// "The stack": every skill in a numbered four-column table. Hovering a row
/// reveals what I use it for.
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  static const _disciplines = [
    _Discipline('Core', [
      'Languages & Frameworks',
      'State Management',
      'Architecture',
    ]),
    _Discipline('Data & backend', [
      'Backend & APIs',
      'Firebase',
      'Local Storage',
    ]),
    _Discipline('Product features', [
      'Real-Time Communication',
      'Payments',
      'UI / UX',
    ]),
    _Discipline('Tooling & release', ['Tools', 'Deployment']),
  ];

  @override
  Widget build(BuildContext context) {
    final byName = {for (final c in SkillsData.categories) c.name: c};
    final groups = [
      for (final d in _disciplines)
        (d.title, [for (final name in d.categories) ...?byName[name]?.skills]),
    ];
    final total = groups.fold<int>(0, (n, g) => n + g.$2.length);

    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: AppSpacing.lg,
            spacing: AppSpacing.xl,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SectionLabel('The stack', index: '06'),
                  const SizedBox(height: AppSpacing.lg),
                  LineReveal(
                    lines: const ['Tools I reach for,', 'every single day.'],
                    lineColors: const [null, AppColors.textMuted],
                    style: AppTypography.display(fluid(context, 36, 64)),
                  ),
                ],
              ),
              Text(
                '$total TOOLS — ${groups.length.toString().padLeft(2, '0')} DISCIPLINES',
                style: AppTypography.eyebrow(color: AppColors.textMuted),
              ),
            ],
          ),
          SizedBox(height: fluid(context, 40, 72)),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 1000 ? 4 : (c.maxWidth > 560 ? 2 : 1);
              final w = (c.maxWidth - 28 * (cols - 1)) / cols;
              return Wrap(
                spacing: 28,
                runSpacing: 48,
                children: [
                  for (var i = 0; i < groups.length; i++)
                    SizedBox(
                      width: w,
                      child: Reveal.staggered(
                        index: i,
                        child: _Column(
                          index: i,
                          title: groups[i].$1,
                          skills: groups[i].$2,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.index,
    required this.title,
    required this.skills,
  });

  final int index;
  final String title;
  final List<Skill> skills;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              (index + 1).toString().padLeft(2, '0'),
              style: AppTypography.numeric(
                const TextStyle(
                  fontSize: 44,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const Spacer(),
            Text(
              skills.length.toString().padLeft(2, '0'),
              style: AppTypography.eyebrow(
                color: AppColors.textMuted,
                size: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 18),
        const HairlineDivider(color: AppColors.textMuted),
        for (final s in skills) _SkillRow(skill: s),
      ],
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill});

  final Skill skill;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.medium,
                  curve: AppCurves.out,
                  width: hovered ? 18 : 0,
                  child: hovered
                      ? const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.textPrimary,
                        )
                      : null,
                ),
                Icon(
                  skill.icon,
                  size: 16,
                  color: hovered ? AppColors.textPrimary : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    skill.name,
                    style: AppTypography.label(
                      TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: hovered
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: AppCurves.out,
              alignment: Alignment.topLeft,
              child: hovered && !context.isMobile
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6, left: 44),
                      child: Text(
                        skill.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
