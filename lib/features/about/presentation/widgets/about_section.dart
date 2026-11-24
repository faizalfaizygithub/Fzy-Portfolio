import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/glow_card.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/animations/drifting_glow.dart';
import '../../../../shared/animations/reveal.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const _paragraphs = [
    "I'm a Flutter Developer based in Calicut, Kerala, with ${AppInfo.experience} years of experience developing cross-platform applications.",
    'I enjoy transforming ideas and Figma designs into functional, scalable, and visually appealing applications.',
    'My experience includes developing healthcare applications, e-commerce platforms, and real-time communication solutions.',
    'I focus on clean code, maintainable architecture, performance optimization, and delivering quality user experiences.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final wide = context.isDesktop;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          index: '01',
          eyebrow: 'About',
          title: 'A Little About Me',
        ),
        const SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < _paragraphs.length; i++)
          Reveal.staggered(
            index: i,
            base: AppDurations.stagger * 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                _paragraphs[i],
                style: i == 0
                    ? theme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontSize: 19)
                    : theme.bodyLarge,
              ),
            ),
          ),
      ],
    );

    return SectionContainer(
      background: DriftingGlow(
        color: AppColors.secondary,
        size: context.responsive<double>(mobile: 420, desktop: 720),
        from: const Alignment(1.1, -0.8),
        to: const Alignment(0.5, 0.6),
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: text),
                const SizedBox(width: AppSpacing.xxxl),
                const Expanded(flex: 5, child: _HighlightGrid()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                text,
                const SizedBox(height: AppSpacing.xl),
                const _HighlightGrid(),
              ],
            ),
    );
  }
}

class _Highlight {
  const _Highlight(this.icon, this.title, this.body, {this.figure});
  final IconData icon;
  final String title;
  final String body;
  final String? figure;
}

class _HighlightGrid extends StatelessWidget {
  const _HighlightGrid();

  static const _items = [
    _Highlight(
      Icons.workspace_premium_rounded,
      'Years Experience',
      'Building production Flutter apps professionally.',
      figure: '${AppInfo.experience}+',
    ),
    _Highlight(
      Icons.devices_rounded,
      'Cross-Platform Development',
      'Android and iOS apps from a single Flutter codebase.',
    ),
    _Highlight(
      Icons.category_rounded,
      'Multiple Application Domains',
      'Healthcare, e-commerce and real-time communication.',
    ),
    _Highlight(
      Icons.all_inclusive_rounded,
      'End-to-End App Development',
      'From Figma designs to Play Store and App Store releases.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 440 ? 2 : 1;
        final width = (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (var i = 0; i < _items.length; i++)
              SizedBox(
                width: width,
                child: Reveal.staggered(
                  index: i,
                  scaleFrom: 0.94,
                  child: _HighlightCard(item: _items[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.item});

  final _Highlight item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return GlowCard(
      child: const SizedBox.shrink(),
      builder: (context, hovered, _) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 176),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.figure != null)
              GradientText(
                item.figure!,
                style: theme.displaySmall?.copyWith(fontSize: 42, height: 1),
              )
            else
              AnimatedContainer(
                duration: AppDurations.medium,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: hovered ? AppColors.brandGradient : null,
                  color: hovered ? null : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                ),
                child: AnimatedRotation(
                  duration: AppDurations.medium,
                  turns: hovered ? 0.05 : 0,
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: hovered ? AppColors.textPrimary : AppColors.highlight,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(item.title, style: theme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(item.body, style: theme.bodySmall),
          ],
        ),
      ),
    );
  }
}
