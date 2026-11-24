import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/glow_card.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/project.dart';
import 'open_project.dart';
import 'phone_composition.dart';

/// Large project card: copy on one side, phone composition on the other.
/// [reversed] swaps the sides for alternating rows.
class ProjectShowcaseCard extends StatelessWidget {
  const ProjectShowcaseCard({
    super.key,
    required this.project,
    this.reversed = false,
  });

  final Project project;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final spotlight = project.isSpotlight;
    final wide = !context.isMobile;
    final visualHeight = context.responsive<double>(
      mobile: 360,
      tablet: 420,
      desktop: spotlight ? 540 : 470,
    );

    return GlowCard(
      accent: project.accent,
      padding: EdgeInsets.zero,
      radius: AppRadius.xl,
      lift: 4,
      semanticLabel: 'Open ${project.name} project details',
      onTap: () => openProject(context, project),
      builder: (context, hovered, _) {
        final copy = _ProjectCopy(project: project, hovered: hovered);
        final visual = ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl - 1),
          child: Container(
            height: visualHeight,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: [
                  project.accent.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    child: PhoneComposition(
                      project: project,
                      height: visualHeight * 0.86,
                      hovered: hovered,
                      phoneCount: context.isMobile ? 2 : 3,
                    ),
                  ),
                ),
                if (!project.hasScreenshots)
                  const Positioned(
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: _IllustrativeBadge(),
                  ),
              ],
            ),
          ),
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [visual, copy],
          );
        }

        final children = [
          Expanded(flex: spotlight ? 5 : 6, child: copy),
          Expanded(flex: spotlight ? 6 : 5, child: visual),
        ];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: reversed ? children.reversed.toList() : children,
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

class _ProjectCopy extends StatelessWidget {
  const _ProjectCopy({required this.project, required this.hovered});

  final Project project;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final spotlight = project.isSpotlight;
    final contributions =
        project.contributions.take(spotlight ? 4 : 3).toList(growable: false);

    return Padding(
      padding: EdgeInsets.all(
        context.responsive<double>(mobile: AppSpacing.lg, desktop: AppSpacing.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxs),
                child: Text(
                  project.number,
                  style: theme.labelSmall?.copyWith(color: project.accent),
                ),
              ),
              TagChip(project.category, accent: project.accent),
              if (spotlight)
                const TagChip(
                  'Spotlight',
                  icon: Icons.auto_awesome_rounded,
                  accent: AppColors.highlight,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            project.name,
            style: (spotlight ? theme.displaySmall : theme.headlineMedium)
                ?.copyWith(
              fontSize: context.responsive<double>(
                mobile: spotlight ? 36 : 30,
                desktop: spotlight ? 52 : 38,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(project.summary, style: theme.bodyLarge?.copyWith(fontSize: 16.5)),
          const SizedBox(height: AppSpacing.lg),
          for (final item in contributions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: project.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(item, style: theme.bodyMedium)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final tech in project.technologies) TagChip(tech),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'View project details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.labelLarge?.copyWith(
                    color: hovered ? project.accent : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              AnimatedSlide(
                duration: AppDurations.fast,
                offset: hovered ? const Offset(0.35, 0) : Offset.zero,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: hovered ? project.accent : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IllustrativeBadge extends StatelessWidget {
  const _IllustrativeBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Illustrative interface. Real screenshots will be added.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.7),
          borderRadius: AppRadius.button,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Illustrative preview',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 11),
        ),
      ),
    );
  }
}
