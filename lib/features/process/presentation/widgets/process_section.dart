import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/line_reveal.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../../shared/animations/scroll_select.dart';

class _Step {
  const _Step(this.title, this.body);
  final String title;
  final String body;
}

/// "A five-step process": a pinned dial that rotates through each step as
/// the page scrolls, with an odometer numeral and swapping copy.
class ProcessSection extends StatelessWidget {
  const ProcessSection({super.key});

  static const steps = [
    _Step(
      'Discover',
      'We pin down the problem, the people using the app and what success '
          'looks like. Requirements become a short, honest scope.',
    ),
    _Step(
      'Design',
      'Figma screens turn into a component plan — tokens, reusable widgets and '
          'every state: loading, empty, error and offline.',
    ),
    _Step(
      'Architect',
      'Clean layers, a repository for every data source and state management '
          'that rebuilds only what changed.',
    ),
    _Step(
      'Build',
      'Feature by feature against real APIs, payments and real-time calls — '
          'profiled on low-end devices, not just my phone.',
    ),
    _Step(
      'Ship',
      'Store-ready builds, Crashlytics watching, and Play Console and App '
          'Store releases handled end to end.',
    ),
  ];

  static const headline = ['A five-step process,', 'never a template.'];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pinned =
        !context.reduceMotion &&
        size.width >= Breakpoints.tablet &&
        size.height >= 600;
    return pinned ? const _PinnedProcess() : const _StaticProcess();
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionLabel('Process', index: '04'),
        const SizedBox(height: AppSpacing.lg),
        LineReveal(
          lines: ProcessSection.headline,
          lineColors: const [null, AppColors.textMuted],
          style: AppTypography.display(fluid(context, 36, 64)),
        ),
      ],
    );
  }
}

class _PinnedProcess extends StatelessWidget {
  const _PinnedProcess();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final n = ProcessSection.steps.length;
    return PinnedSection(
      scrollLength: size.height * 0.75 * n,
      builder: (context, progress) {
        // Dwell on each step: ease the fractional part between steps.
        final raw = (progress * 1.08 - 0.04).clamp(0.0, 1.0) * (n - 1);
        final i = raw.floor().clamp(0, n - 2);
        final frac = Curves.easeInOutCubic.transform((raw - i).clamp(0.0, 1.0));
        final position = (i + frac).toDouble();
        final active = position.round();
        return _ProcessStage(
          position: position,
          active: active,
          progress: progress,
        );
      },
    );
  }
}

class _ProcessStage extends StatelessWidget {
  const _ProcessStage({
    required this.position,
    required this.active,
    required this.progress,
  });

  /// Continuous step index (0..n-1).
  final double position;
  final int active;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final g = gutter(context);
    final steps = ProcessSection.steps;
    final radius = (size.height * 0.36).clamp(220.0, 400.0);
    final centre = Offset(-radius * 0.38, size.height * 0.58);
    final numeralSize = (radius * 0.62).clamp(120.0, 240.0);
    final textLeft = centre.dx + radius + numeralSize * 1.25 + 56;

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          // Glow behind the dial.
          Positioned(
            left: centre.dx + radius * 0.2,
            top: centre.dy - radius,
            width: radius * 2,
            height: radius * 2,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x26FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _DialPainter(
                centre: centre,
                radius: radius,
                position: position,
                count: steps.length,
                labelStyle: AppTypography.numeric(
                  TextStyle(
                    fontSize: (radius * 0.11).clamp(22.0, 40.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          // Heading.
          Positioned(left: g, top: 104, right: g, child: const _Heading()),
          // Odometer numeral.
          Positioned(
            left: centre.dx + radius + 64,
            top: centre.dy - numeralSize * 0.75,
            height: numeralSize * 1.5,
            width: numeralSize * 1.3,
            child: _Odometer(
              position: position,
              size: numeralSize,
              count: steps.length,
            ),
          ),
          // Step copy.
          Positioned(
            left: textLeft,
            right: g,
            top: centre.dy - 90,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 550),
                switchInCurve: AppCurves.power4Out,
                transitionBuilder: (child, a) => ClipRect(
                  child: FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.35),
                        end: Offset.zero,
                      ).animate(a),
                      child: child,
                    ),
                  ),
                ),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topLeft,
                  children: [...previous, ?current],
                ),
                child: Column(
                  key: ValueKey(active),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP ${(active + 1).toString().padLeft(2, '0')}',
                      style: AppTypography.eyebrow(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      steps[active].title,
                      style: AppTypography.display(fluid(context, 36, 60)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      steps[active].body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Step tabs.
          Positioned(
            left: g,
            right: g,
            bottom: 36,
            child: _StepTabs(active: active, progress: progress),
          ),
        ],
      ),
    );
  }
}

class _Odometer extends StatelessWidget {
  const _Odometer({
    required this.position,
    required this.size,
    required this.count,
  });

  final double position;
  final double size;
  final int count;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.numeric(
      TextStyle(
        fontSize: size,
        height: 1.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final line = size * 1.5;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (r) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black,
          Colors.black,
          Colors.transparent,
        ],
        stops: [0, 0.18, 0.82, 1],
      ).createShader(r),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxHeight: double.infinity,
          child: Transform.translate(
            offset: Offset(0, -position * line),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < count; i++)
                  SizedBox(
                    height: line,
                    child: Text(
                      (i + 1).toString().padLeft(2, '0'),
                      style: style,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTabs extends StatelessWidget {
  const _StepTabs({required this.active, required this.progress});

  final int active;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final steps = ProcessSection.steps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Container(height: 1, color: AppColors.border),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(height: 1, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 0; i < steps.length; i++)
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: AppDurations.medium,
                  style: AppTypography.label(
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: i == active
                          ? AppColors.textPrimary
                          : i < active
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text((i + 1).toString().padLeft(2, '0')),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          steps[i].title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Bezel with fine ticks, numbered notches every [_stepAngle], a progress arc
/// and a fixed active marker at three o'clock. Rotates with [position].
class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.centre,
    required this.radius,
    required this.position,
    required this.count,
    required this.labelStyle,
  });

  final Offset centre;
  final double radius;
  final double position;
  final int count;
  final TextStyle labelStyle;

  static const _stepAngle = 22 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final rotation = -position * _stepAngle;

    // Outer and inner rings.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.border;
    canvas.drawCircle(centre, radius, ring);
    canvas.drawCircle(centre, radius * 0.76, ring);
    canvas.drawCircle(
      centre,
      radius * 1.32,
      ring..color = const Color(0xFF1A1A1A),
    );

    // Rotating wireframe inside the dial.
    final art = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.borderStrong;
    for (var k = 0; k < 6; k++) {
      final a = rotation * 1.6 + k * math.pi / 6;
      canvas.save();
      canvas.translate(centre.dx, centre.dy);
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 1.3,
          height: radius * 0.42,
        ),
        art,
      );
      canvas.restore();
    }

    // Fine ticks around the bezel.
    final tick = Paint()
      ..strokeWidth = 1.2
      ..color = AppColors.borderStrong;
    for (var d = 0; d < 360; d += 3) {
      final a = d * math.pi / 180 + rotation;
      final o = centre + Offset(math.cos(a), math.sin(a)) * radius;
      final in_ = centre + Offset(math.cos(a), math.sin(a)) * (radius - 8);
      canvas.drawLine(in_, o, tick);
    }

    // Progress arc from the first step to the current position.
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = AppColors.textPrimary;
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..color = AppColors.textPrimary.withValues(alpha: 0.08);
    final rect = Rect.fromCircle(center: centre, radius: radius);
    final sweep = position * _stepAngle;
    canvas.drawArc(rect, -sweep, sweep, false, glow);
    canvas.drawArc(rect, -sweep, sweep, false, arc);

    // Notches and labels.
    for (var i = 0; i < count; i++) {
      final a = i * _stepAngle + rotation;
      final dir = Offset(math.cos(a), math.sin(a));
      final distance = (i - position).abs();
      final major = Paint()
        ..strokeWidth = 1.4
        ..color = distance < 0.5 ? AppColors.textPrimary : AppColors.textMuted;
      canvas.drawLine(
        centre + dir * (radius - 18),
        centre + dir * (radius + 6),
        major,
      );
      canvas.drawCircle(
        centre + dir * radius,
        distance < 0.5 ? 0 : 3,
        Paint()
          ..color = i < position
              ? AppColors.textSecondary
              : AppColors.textMuted,
      );

      // Labels fade out as they reach the active marker (the odometer shows it).
      final alpha = (distance * 1.6).clamp(0.0, 1.0);
      if (alpha <= 0.02) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: (i + 1).toString().padLeft(2, '0'),
          style: labelStyle.copyWith(
            color:
                (i < position ? AppColors.textSecondary : AppColors.textMuted)
                    .withValues(alpha: alpha),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = centre + dir * (radius + 22 + tp.width * 0.6);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(a);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Fixed active marker at three o'clock.
    final marker = centre + Offset(radius, 0);
    canvas.drawCircle(marker, 7, Paint()..color = AppColors.textPrimary);
    canvas.drawCircle(
      marker,
      14,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.textPrimary.withValues(alpha: 0.25),
    );
    canvas.drawLine(
      marker + const Offset(22, 0),
      marker + const Offset(52, 0),
      Paint()
        ..strokeWidth = 1
        ..color = AppColors.textPrimary,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.position != position || old.radius != radius || old.centre != centre;
}

class _StaticProcess extends StatelessWidget {
  const _StaticProcess();

  @override
  Widget build(BuildContext context) {
    final steps = ProcessSection.steps;
    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Heading(),
          SizedBox(height: fluid(context, 40, 64)),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 900 ? 5 : (c.maxWidth > 560 ? 2 : 1);
              final w = (c.maxWidth - 24 * (cols - 1)) / cols;
              return Wrap(
                spacing: 24,
                runSpacing: 36,
                children: [
                  for (var i = 0; i < steps.length; i++)
                    SizedBox(
                      width: w,
                      child: Reveal.staggered(
                        index: i,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (i + 1).toString().padLeft(2, '0'),
                              style: AppTypography.numeric(
                                const TextStyle(
                                  fontSize: 64,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const HairlineDivider(),
                            const SizedBox(height: 16),
                            Text(
                              steps[i].title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              steps[i].body,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
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
