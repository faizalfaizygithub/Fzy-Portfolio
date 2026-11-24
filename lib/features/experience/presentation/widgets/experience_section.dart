import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/glow_card.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../../shared/animations/scroll_aware.dart';
import '../../../home/presentation/providers/navigation_provider.dart';
import '../../data/experience_data.dart';

/// The line "draws" down to this fraction of the viewport height.
const _drawLine = 0.65;

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<NavigationProvider>().scrollController;
    final railWidth = context.responsive<double>(mobile: 28, desktop: 56);
    final reduce = context.reduceMotion;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '03',
            eyebrow: 'Experience',
            title: 'Where I\'ve Worked',
            subtitle: 'Building and shipping Flutter apps in product teams.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          Stack(
            children: [
              // Timeline rail: a dim track with a gradient line that grows as
              // the reader scrolls through the section.
              Positioned(
                left: railWidth / 2 - 1,
                top: 8,
                bottom: 0,
                width: 2,
                child: ScrollAware<double>(
                  controller: controller,
                  initial: reduce ? 1 : 0,
                  compute: (top, height, viewport) => reduce
                      ? 1
                      : (((viewport * _drawLine - top) / height).clamp(0.0, 1.0) * 100)
                              .roundToDouble() /
                          100,
                  builder: (context, progress) => Stack(
                    children: [
                      const Positioned.fill(child: ColoredBox(color: AppColors.border)),
                      Align(
                        alignment: Alignment.topCenter,
                        child: FractionallySizedBox(
                          heightFactor: progress,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.highlight, AppColors.primary, AppColors.secondary],
                              ),
                              boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 10)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  for (var i = 0; i < ExperienceData.items.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == ExperienceData.items.length - 1 ? 0 : AppSpacing.xl,
                      ),
                      child: _TimelineEntry(
                        experience: ExperienceData.items[i],
                        railWidth: railWidth,
                        controller: controller,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.experience,
    required this.railWidth,
    required this.controller,
  });

  final Experience experience;
  final double railWidth;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final gap = context.responsive<double>(mobile: AppSpacing.md, desktop: AppSpacing.lg);
    final reduce = context.reduceMotion;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: railWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ScrollAware<bool>(
              controller: controller,
              initial: reduce,
              compute: (top, _, viewport) => reduce || top < viewport * _drawLine,
              builder: (context, active) => _TimelineDot(active: active),
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Reveal(
            offset: const Offset(0.04, 0),
            child: _ExperienceCard(experience: experience),
          ),
        ),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: AppCurves.emphasized,
        width: active ? 18 : 12,
        height: active ? 18 : 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.highlight : AppColors.background,
          border: Border.all(
            color: active ? AppColors.textPrimary : AppColors.border,
            width: active ? 3 : 2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.9), blurRadius: 18, spreadRadius: 2),
                ]
              : null,
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final wide = !context.isMobile;
    final columns = context.isDesktop ? 2 : 1;

    final meta = Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        TagChip(experience.period, icon: Icons.calendar_today_rounded),
        TagChip(experience.location, icon: Icons.location_on_outlined),
      ],
    );

    return GlowCard(
      padding: EdgeInsets.all(wide ? AppSpacing.xl : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(experience.role, style: theme.headlineSmall),
                        if (experience.current)
                          const TagChip('Current', accent: AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      experience.company,
                      style: theme.titleMedium?.copyWith(color: AppColors.highlight),
                    ),
                  ],
                ),
              ),
              if (wide) ...[const SizedBox(width: AppSpacing.md), meta],
            ],
          ),
          if (!wide) ...[const SizedBox(height: AppSpacing.md), meta],
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth =
                  (constraints.maxWidth - AppSpacing.lg * (columns - 1)) / columns;
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final r in experience.responsibilities)
                    SizedBox(
                      width: itemWidth,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(Icons.arrow_right_alt_rounded, size: 16, color: AppColors.highlight),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(child: Text(r, style: theme.bodyMedium)),
                        ],
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
