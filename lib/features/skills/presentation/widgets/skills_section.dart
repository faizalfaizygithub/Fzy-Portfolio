import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/glow_card.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../../shared/models/skill.dart';
import '../../data/skills_data.dart';

class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  /// null = all categories.
  SkillCategory? _selected;

  List<(Skill, SkillCategory)> get _visible => [
        for (final c in SkillsData.categories)
          if (_selected == null || _selected == c)
            for (final s in c.skills) (s, c),
      ];

  @override
  Widget build(BuildContext context) {
    final skills = _visible;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '02',
            eyebrow: 'Skills',
            title: 'Technologies I Work With',
            subtitle: 'The tools, patterns and platforms I use to ship production Flutter apps. '
                'Pick a category to filter.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Reveal(
            delay: AppDurations.stagger * 3,
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _FilterChip(
                  label: 'All',
                  icon: Icons.apps_rounded,
                  count: SkillsData.categories.fold(0, (n, c) => n + c.skills.length),
                  selected: _selected == null,
                  onTap: () => setState(() => _selected = null),
                ),
                for (final c in SkillsData.categories)
                  _FilterChip(
                    label: c.name,
                    icon: c.icon,
                    count: c.skills.length,
                    selected: _selected == c,
                    onTap: () => setState(() => _selected = c),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AnimatedSize(
            duration: AppDurations.medium,
            curve: AppCurves.smooth,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: AppDurations.medium,
              switchInCurve: AppCurves.smooth,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: _SkillGrid(
                key: ValueKey(_selected?.name ?? 'all'),
                skills: skills,
                showCategory: _selected == null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillGrid extends StatelessWidget {
  const _SkillGrid({super.key, required this.skills, required this.showCategory});

  final List<(Skill, SkillCategory)> skills;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final columns = w >= 1100 ? 4 : (w >= 760 ? 3 : (w >= 480 ? 2 : 1));
        final itemWidth = (w - AppSpacing.md * (columns - 1)) / columns;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (var i = 0; i < skills.length; i++)
              SizedBox(
                width: itemWidth,
                // First time the grid scrolls into view the cards stagger in
                // (Reveal); on filter changes they cascade via the tween.
                child: Reveal.staggered(
                  index: i % (columns * 2),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: reduce ? 1 : 0, end: 1),
                    duration: AppDurations.medium + AppDurations.stagger * (i % 12) * 0.6,
                    curve: AppCurves.emphasized,
                    builder: (context, t, child) => Opacity(
                      opacity: t,
                      child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
                    ),
                    child: _SkillCard(
                      skill: skills[i].$1,
                      category: showCategory ? skills[i].$2.name : null,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.skill, this.category});

  final Skill skill;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      lift: 3,
      radius: AppRadius.md,
      child: const SizedBox.shrink(),
      builder: (context, hovered, _) => SizedBox(
        height: category != null ? 56 : 48,
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppDurations.medium,
              curve: AppCurves.smooth,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: hovered ? AppColors.brandGradient : null,
                color: hovered ? null : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: hovered
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 14)]
                    : null,
              ),
              child: AnimatedScale(
                duration: AppDurations.medium,
                curve: AppCurves.emphasized,
                scale: hovered ? 1.08 : 1,
                child: Icon(
                  skill.icon,
                  size: 18,
                  color: hovered ? AppColors.textPrimary : AppColors.highlight,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    skill.name,
                    style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      category!.toUpperCase(),
                      style: theme.labelSmall?.copyWith(
                        fontSize: 9.0,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      child: HoverBuilder(
        onTap: onTap,
        semanticLabel: 'Show $label skills',
        builder: (context, hovered) => AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.brandGradient : null,
            color: selected ? null : (hovered ? AppColors.card : AppColors.card.withValues(alpha: 0.5)),
            borderRadius: AppRadius.button,
            border: Border.all(
              color: selected ? Colors.transparent : (hovered ? AppColors.highlight : AppColors.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: selected ? AppColors.textPrimary : AppColors.highlight),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.labelMedium?.copyWith(
                    color: selected || hovered ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: theme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  letterSpacing: 0,
                  color: selected ? AppColors.textPrimary.withValues(alpha: 0.75) : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
