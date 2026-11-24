import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/animations/drifting_glow.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../../shared/animations/tilt_card.dart';

class _Expertise {
  const _Expertise(this.number, this.icon, this.title, this.body, this.tags);
  final String number;
  final IconData icon;
  final String title;
  final String body;
  final List<String> tags;
}

class ExpertiseSection extends StatelessWidget {
  const ExpertiseSection({super.key});

  static const _items = [
    _Expertise(
      '01',
      Icons.layers_rounded,
      'Clean Architecture',
      'Building maintainable and scalable applications using Clean Architecture, Repository Pattern, and SOLID principles.',
      ['Clean Architecture', 'Repository', 'SOLID'],
    ),
    _Expertise(
      '02',
      Icons.api_rounded,
      'API Integration',
      'Integrating REST APIs, JSON serialization, and WebSockets for reliable application communication.',
      ['REST', 'JSON', 'WebSockets'],
    ),
    _Expertise(
      '03',
      Icons.videocam_rounded,
      'Real-Time Communication',
      'Implementing audio/video calling and real-time communication features using Agora and Firebase.',
      ['Agora', 'Firebase', 'FCM'],
    ),
    _Expertise(
      '04',
      Icons.speed_rounded,
      'Performance Optimization',
      'Improving application responsiveness through efficient state management, lazy loading, and performance debugging.',
      ['State management', 'Lazy loading', 'Profiling'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive(mobile: 1, tablet: 2, desktop: 4);

    return SectionContainer(
      background: DriftingGlow(
        color: AppColors.primary,
        size: context.responsive<double>(mobile: 400, desktop: 700),
        from: const Alignment(-0.2, 0.2),
        to: const Alignment(0.6, 0.8),
        opacity: 0.18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '05',
            eyebrow: 'Expertise',
            title: 'Beyond Writing Code',
            subtitle: 'Capabilities I\'ve built through professional, production work.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          LayoutBuilder(
            builder: (context, constraints) {
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
                        offset: const Offset(0, 0.15),
                        child: _ExpertiseCard(item: _items[i]),
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

class _ExpertiseCard extends StatelessWidget {
  const _ExpertiseCard({required this.item});

  final _Expertise item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return TiltCard(
      builder: (context, hovered) => AnimatedContainer(
        duration: AppDurations.medium,
        curve: AppCurves.smooth,
        constraints: BoxConstraints(minHeight: context.isMobile ? 0 : 340),
        padding: const EdgeInsets.all(AppSpacing.lg + 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: hovered ? AppColors.primary : AppColors.border),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: hovered
                ? [AppColors.primary.withValues(alpha: 0.22), AppColors.card]
                : [AppColors.card, AppColors.card],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: hovered ? 0.3 : 0),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.medium,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: hovered ? AppColors.brandGradient : null,
                    color: hovered ? null : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: hovered ? Colors.transparent : AppColors.border),
                  ),
                  child: Icon(item.icon, color: hovered ? AppColors.textPrimary : AppColors.highlight),
                ),
                const Spacer(),
                // Outlined number that fills with colour on hover.
                AnimatedDefaultTextStyle(
                  duration: AppDurations.medium,
                  style: theme.displaySmall!.copyWith(
                    fontSize: 48,
                    height: 1,
                    color: hovered
                        ? AppColors.highlight.withValues(alpha: 0.9)
                        : AppColors.border,
                  ),
                  child: Text(item.number),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(item.title, style: theme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(item.body, style: theme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in item.tags)
                  Text(
                    '#${t.replaceAll(' ', '')}',
                    style: theme.labelSmall?.copyWith(
                      letterSpacing: 0.2,
                      color: hovered ? AppColors.highlight : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
