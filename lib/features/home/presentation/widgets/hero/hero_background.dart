import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ambient_glow.dart';

/// Slowly drifting gradient lights, a static dot grid and a few particles.
/// Everything animates from the shared [ambient] loop (0 → 1, repeating).
class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key, required this.ambient});

  final Animation<double> ambient;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final glow = math.max(w, h) * 0.7;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: RepaintBoundary(child: CustomPaint(painter: _GridPainter())),
            ),
            AnimatedBuilder(
              animation: ambient,
              builder: (context, _) {
                final t = ambient.value * 2 * math.pi;
                return Stack(
                  children: [
                    Positioned(
                      left: w * 0.55 + math.cos(t) * w * 0.06 - glow / 2,
                      top: h * 0.25 + math.sin(t) * h * 0.06 - glow / 2,
                      child: AmbientGlow(color: AppColors.primary, size: glow, opacity: 0.32),
                    ),
                    Positioned(
                      left: w * 0.1 + math.sin(t) * w * 0.05 - glow / 2,
                      top: h * 0.75 + math.cos(t) * h * 0.05 - glow / 2,
                      child: AmbientGlow(color: AppColors.secondary, size: glow * 0.8, opacity: 0.22),
                    ),
                  ],
                );
              },
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _ParticlePainter(ambient)),
              ),
            ),
            // Fade the bottom into the page background.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 160,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00080812), AppColors.background],
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

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 36.0;
    final center = Offset(size.width * 0.6, size.height * 0.4);
    final maxDist = size.longestSide * 0.6;
    final paint = Paint();
    for (var x = gap / 2; x < size.width; x += gap) {
      for (var y = gap / 2; y < size.height; y += gap) {
        final d = (Offset(x, y) - center).distance / maxDist;
        final a = (1 - d).clamp(0.0, 1.0) * 0.16;
        if (a <= 0.01) continue;
        paint.color = AppColors.highlight.withValues(alpha: a);
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  static final _seeds = List.generate(26, (i) {
    final r = math.Random(i * 7919);
    return (r.nextDouble(), r.nextDouble(), r.nextDouble() * 1.6 + 0.6, r.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final (x, y, radius, phase) in _seeds) {
      // Each particle drifts upward and wraps around.
      final progress = (animation.value + phase) % 1.0;
      final dy = (y - progress * 0.35) % 1.0;
      final twinkle = 0.5 + 0.5 * math.sin((progress + phase) * 2 * math.pi * 3);
      paint.color = AppColors.highlight.withValues(alpha: 0.15 + twinkle * 0.35);
      canvas.drawCircle(
        Offset(x * size.width, dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => false;
}
