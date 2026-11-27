import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/count_up.dart';
import '../../../../shared/animations/line_reveal.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../experience/data/experience_data.dart';
import '../../../projects/data/projects_local_data_source.dart';
import '../../../skills/data/skills_data.dart';

class _Capability {
  const _Capability(this.title, this.body, this.tools);
  final String title;
  final String body;
  final List<String> tools;
}

/// "Code that carries the whole product": three tall spotlight panels and a
/// row of counting stats.
class ExpertiseSection extends StatelessWidget {
  const ExpertiseSection({super.key});

  static const _items = [
    _Capability(
      'Clean architecture',
      'Feature-first layers, a repository per data source and Provider-driven '
          'state that stays readable at screen fifty, not just screen five.',
      ['Clean Architecture', 'Repository', 'SOLID', 'Provider'],
    ),
    _Capability(
      'Real-time & payments',
      'Agora audio and video calls with FCM call alerts, live data over '
          'WebSockets, and Razorpay or Cashfree checkouts that never double-charge.',
      ['Agora', 'WebSockets', 'FCM', 'Razorpay'],
    ),
    _Capability(
      'Performance first',
      'Lazy loading, targeted rebuilds and profiling on real devices — then '
          'Crashlytics and store releases to keep it fast after launch.',
      ['DevTools', 'Crashlytics', 'Play Console', 'App Store'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive(mobile: 1, tablet: 1, desktop: 3);
    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Capabilities', index: '05'),
          const SizedBox(height: AppSpacing.lg),
          LineReveal(
            lines: const ['Code that carries', 'the whole product.'],
            lineColors: const [null, AppColors.textMuted],
            style: AppTypography.display(fluid(context, 36, 72)),
          ),
          SizedBox(height: fluid(context, 40, 72)),
          if (cols == 3)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(
                      child: Reveal.staggered(
                        index: i,
                        offset: const Offset(0, 0.1),
                        child: _SpotlightPanel(index: i, item: _items[i]),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            for (var i = 0; i < _items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Reveal(
                  child: _SpotlightPanel(index: i, item: _items[i]),
                ),
              ),
          SizedBox(height: fluid(context, 56, 96)),
          const _Stats(),
        ],
      ),
    );
  }
}

/// Panel with a soft light that follows the pointer.
class _SpotlightPanel extends StatefulWidget {
  const _SpotlightPanel({required this.index, required this.item});

  final int index;
  final _Capability item;

  @override
  State<_SpotlightPanel> createState() => _SpotlightPanelState();
}

class _SpotlightPanelState extends State<_SpotlightPanel> {
  Offset? _pointer;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hovered = _pointer != null;

    return MouseRegion(
      onHover: (e) => setState(() => _pointer = e.localPosition),
      onExit: (_) => setState(() => _pointer = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: AppCurves.out,
        transform: Matrix4.translationValues(0, hovered ? -6 : 0, 0),
        constraints: BoxConstraints(minHeight: fluid(context, 360, 460)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: hovered ? AppColors.borderStrong : AppColors.border,
          ),
          gradient: AppColors.panelGlow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (_pointer != null)
              Positioned(
                left: _pointer!.dx - 220,
                top: _pointer!.dy - 220,
                width: 440,
                height: 440,
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(fluid(context, 24, 36)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        (widget.index + 1).toString().padLeft(2, '0'),
                        style: AppTypography.numeric(
                          const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        duration: AppDurations.medium,
                        curve: AppCurves.spring,
                        turns: hovered ? 0.125 : 0,
                        child: const Icon(
                          Icons.north_east_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: fluid(context, 96, 140)),
                  Text(
                    item.title,
                    style: AppTypography.heading(
                      TextStyle(
                        fontSize: fluid(context, 26, 32),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                        height: 1.1,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in item.tools) Pill(t, dense: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final skills = SkillsData.categories.fold<int>(
      0,
      (n, c) => n + c.skills.length,
    );
    final stats = <(double, int, int, String, String)>[
      (double.parse(AppInfo.experience), 1, 0, '+', 'years shipping Flutter'),
      (
        ProjectsLocalDataSource.projects.length.toDouble(),
        0,
        2,
        '',
        'production apps',
      ),
      (ExperienceData.items.length.toDouble(), 0, 2, '', 'product teams'),
      (skills.toDouble(), 0, 2, '', 'tools & skills'),
    ];
    final style = AppTypography.numeric(
      TextStyle(
        fontSize: fluid(context, 56, 96),
        height: 1,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );

    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 820 ? 4 : 2;
        final w = (c.maxWidth - 24 * (cols - 1)) / cols;
        return Wrap(
          spacing: 24,
          runSpacing: 40,
          children: [
            for (final (value, decimals, pad, suffix, label) in stats)
              SizedBox(
                width: w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HairlineDivider(),
                    const SizedBox(height: 20),
                    CountUp(
                      value: value,
                      decimals: decimals,
                      padLeft: pad,
                      suffix: suffix,
                      style: style,
                    ),
                    const SizedBox(height: 8),
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
