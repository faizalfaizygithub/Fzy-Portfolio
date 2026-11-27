import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_sections.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/line_reveal.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../../shared/animations/scroll_select.dart';
import '../../../home/presentation/providers/navigation_provider.dart';
import '../../domain/project.dart';
import '../providers/projects_provider.dart';
import 'open_project.dart';
import 'phone_composition.dart';

/// Selected work. On desktop the section pins and vertical scrolling drives
/// a horizontal track of large project panels; elsewhere it's a stack.
class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  static const headline = ['Apps that ship,', 'stories that stick.'];

  @override
  Widget build(BuildContext context) {
    final projects = context.read<ProjectsProvider>().projects;
    final size = MediaQuery.sizeOf(context);
    final horizontal =
        context.isDesktop && !context.reduceMotion && size.height >= 620;
    return horizontal
        ? _HorizontalWork(projects: projects)
        : _StackedWork(projects: projects);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionLabel(
          'Selected work · ${count.toString().padLeft(2, '0')} apps',
          index: '03',
        ),
        const SizedBox(height: AppSpacing.lg),
        LineReveal(
          lines: ProjectsSection.headline,
          lineColors: const [null, AppColors.textMuted],
          style: AppTypography.display(fluid(context, 40, 80)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop: pinned horizontal track.

class _HorizontalWork extends StatelessWidget {
  const _HorizontalWork({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final g = gutter(context);
    final introW = (size.width * 0.42).clamp(420.0, 620.0);
    final cardW = (size.width * 0.72).clamp(760.0, 1120.0);
    const gap = 32.0;
    final outroW = (size.width * 0.36).clamp(360.0, 520.0);
    final trackW = g + introW + projects.length * (cardW + gap) + outroW + g;
    final scrollLength = (trackW - size.width).clamp(0.0, double.infinity);

    return PinnedSection(
      scrollLength: scrollLength,
      builder: (context, progress) {
        final dx = -progress * scrollLength;
        final active =
            ((progress * scrollLength - introW * 0.5) / (cardW + gap))
                .round()
                .clamp(0, projects.length - 1);

        return ColoredBox(
          color: AppColors.background,
          child: Column(
            children: [
              const SizedBox(height: 96),
              Expanded(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: trackW,
                    minWidth: trackW,
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: g),
                          SizedBox(
                            width: introW,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 48,
                                bottom: 40,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Header(count: projects.length),
                                  const SizedBox(height: AppSpacing.xl),
                                  Text(
                                    'Five production apps across healthcare, '
                                    'commerce and real-time communication. '
                                    'Keep scrolling →',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          for (var i = 0; i < projects.length; i++) ...[
                            SizedBox(
                              width: cardW,
                              child: _WorkPanel(
                                project: projects[i],
                                // Card centre relative to screen centre, -1..1.
                                parallax:
                                    ((g +
                                            introW +
                                            i * (cardW + gap) +
                                            cardW / 2 +
                                            dx) -
                                        size.width / 2) /
                                    size.width,
                              ),
                            ),
                            const SizedBox(width: gap),
                          ],
                          SizedBox(width: outroW, child: const _Outro()),
                          SizedBox(width: g),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(g, 24, g + 72, 32),
                child: _ProgressRail(
                  progress: progress,
                  active: active,
                  projects: projects,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRail extends StatelessWidget {
  const _ProgressRail({
    required this.progress,
    required this.active,
    required this.projects,
  });

  final double progress;
  final int active;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final numeral = AppTypography.numeric(
      const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
    return Row(
      children: [
        AnimatedSwitcher(
          duration: AppDurations.medium,
          transitionBuilder: (child, a) => ClipRect(
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(a),
              child: child,
            ),
          ),
          child: Text(
            (active + 1).toString().padLeft(2, '0'),
            key: ValueKey(active),
            style: numeral,
          ),
        ),
        Text(
          ' / ${projects.length.toString().padLeft(2, '0')}',
          style: numeral.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Stack(
            children: [
              Container(height: 1, color: AppColors.borderStrong),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(height: 1, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        AnimatedSwitcher(
          duration: AppDurations.medium,
          child: Text(
            projects[active].name.toUpperCase(),
            key: ValueKey(active),
            style: AppTypography.eyebrow(),
          ),
        ),
      ],
    );
  }
}

class _Outro extends StatelessWidget {
  const _Outro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Got an app\nin mind?',
            style: AppTypography.display(fluid(context, 36, 56)),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Start a project',
            icon: Icons.north_east_rounded,
            onPressed: () =>
                context.read<NavigationProvider>().scrollTo(AppSection.contact),
          ),
        ],
      ),
    );
  }
}

/// Large project panel: copy on the left, phones on the right.
class _WorkPanel extends StatelessWidget {
  const _WorkPanel({required this.project, this.parallax = 0});

  final Project project;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: () => openProject(context, project),
      semanticLabel: 'Open ${project.name} case study',
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: AppCurves.out,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: hovered ? AppColors.textMuted : AppColors.border,
          ),
          gradient: RadialGradient(
            center: const Alignment(0.6, -0.2),
            radius: 1.2,
            colors: [
              project.accent.withValues(alpha: hovered ? 0.22 : 0.14),
              AppColors.raised,
              AppColors.backgroundAlt,
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, c) => Row(
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(44, 40, 12, 40),
                  child: _PanelCopy(project: project, hovered: hovered),
                ),
              ),
              Expanded(
                flex: 6,
                child: Transform.translate(
                  offset: Offset(parallax * -90, 0),
                  child: Center(
                    child: PhoneComposition(
                      project: project,
                      height: (c.maxHeight * 0.86).clamp(280.0, 640.0),
                      hovered: hovered,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelCopy extends StatelessWidget {
  const _PanelCopy({
    required this.project,
    required this.hovered,
    this.compact = false,
  });

  final Project project;
  final bool hovered;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Row(
          children: [
            Text(
              project.number,
              style: AppTypography.numeric(
                TextStyle(
                  fontSize: compact ? 44 : fluid(context, 56, 92),
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const Spacer(),
            Text('( CASE )', style: AppTypography.eyebrow(size: 11)),
          ],
        ),
        if (compact) const SizedBox(height: AppSpacing.lg) else const Spacer(),
        Text(
          project.category.toUpperCase(),
          style: AppTypography.eyebrow(size: 11.5),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          project.name,
          style: AppTypography.display(
            compact ? fluid(context, 38, 52) : fluid(context, 44, 76),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          project.summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in project.technologies.take(compact ? 3 : 4))
              Pill(t, dense: true),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            AnimatedContainer(
              duration: AppDurations.medium,
              curve: AppCurves.out,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hovered ? AppColors.cream : Colors.transparent,
                border: Border.all(
                  color: hovered ? AppColors.cream : AppColors.borderStrong,
                ),
              ),
              child: AnimatedRotation(
                duration: AppDurations.medium,
                curve: AppCurves.spring,
                turns: hovered ? 0.125 : 0,
                child: Icon(
                  Icons.north_east_rounded,
                  size: 18,
                  color: hovered
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                'View case study',
                style: AppTypography.label(
                  const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile / tablet / reduced motion: stacked cards.

class _StackedWork extends StatelessWidget {
  const _StackedWork({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final twoCol = context.isTablet || context.isDesktop;
    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(count: projects.length),
          SizedBox(height: fluid(context, 40, 72)),
          for (var i = 0; i < projects.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Reveal(
                offset: const Offset(0, 0.08),
                child: _StackedCard(project: projects[i], twoCol: twoCol),
              ),
            ),
        ],
      ),
    );
  }
}

class _StackedCard extends StatelessWidget {
  const _StackedCard({required this.project, required this.twoCol});

  final Project project;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: () => openProject(context, project),
      semanticLabel: 'Open ${project.name} case study',
      builder: (context, hovered) {
        final phones = ScrollSelect<double>(
          initial: 0.5,
          select: (m) => quantize(m.passThrough, 200),
          builder: (context, p, child) => Transform.translate(
            offset: Offset(0, context.reduceMotion ? 0 : (p - 0.5) * -40),
            child: child,
          ),
          child: PhoneComposition(
            project: project,
            height: twoCol ? 400 : 320,
            hovered: hovered,
          ),
        );
        final copy = _PanelCopy(
          project: project,
          hovered: hovered,
          compact: true,
        );
        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: AppCurves.out,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: hovered ? AppColors.textMuted : AppColors.border,
            ),
            gradient: RadialGradient(
              center: const Alignment(0, -0.6),
              radius: 1.2,
              colors: [
                project.accent.withValues(alpha: 0.16),
                AppColors.raised,
                AppColors.backgroundAlt,
              ],
              stops: const [0, 0.55, 1],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(fluid(context, 20, 36)),
          child: twoCol
              ? Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: phones),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRect(child: phones),
                    const SizedBox(height: AppSpacing.lg),
                    copy,
                  ],
                ),
        );
      },
    );
  }
}
