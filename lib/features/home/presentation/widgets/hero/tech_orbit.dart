import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';

class _Tech {
  const _Tech(this.label, this.icon, this.color);
  final String label;
  final Widget icon;
  final Color color;
}

/// Interactive technology orbit: a glowing Flutter core with technology
/// badges travelling along two rings. Driven by the shared [ambient] loop.
class TechOrbit extends StatelessWidget {
  const TechOrbit({super.key, required this.ambient, required this.size});

  final Animation<double> ambient;
  final double size;

  static final _inner = <_Tech>[
    _Tech('Dart', const Icon(Icons.data_object_rounded, size: 16, color: Color(0xFF40C4FF)), const Color(0xFF40C4FF)),
    _Tech('Firebase', Icon(FontAwesomeIcons.fire.data, size: 14, color: const Color(0xFFFFB300)), const Color(0xFFFFB300)),
    _Tech('Provider', const Icon(Icons.account_tree_rounded, size: 16, color: AppColors.highlight), AppColors.highlight),
  ];

  static final _outer = <_Tech>[
    _Tech('Agora', const Icon(Icons.videocam_rounded, size: 16, color: Color(0xFF38BDF8)), const Color(0xFF38BDF8)),
    _Tech('REST', const Icon(Icons.api_rounded, size: 16, color: Color(0xFF34D399)), const Color(0xFF34D399)),
    _Tech('Git', Icon(FontAwesomeIcons.gitAlt.data, size: 14, color: const Color(0xFFF05033)), const Color(0xFFF05033)),
    _Tech('Figma', Icon(FontAwesomeIcons.figma.data, size: 14, color: const Color(0xFFF472B6)), const Color(0xFFF472B6)),
    _Tech('WebSockets', const Icon(Icons.sync_alt_rounded, size: 16, color: Color(0xFFF5B971)), const Color(0xFFF5B971)),
  ];

  @override
  Widget build(BuildContext context) {
    final innerR = size * 0.30;
    final outerR = size * 0.45;
    final innerBadges = [for (final t in _inner) _Badge(tech: t)];
    final outerBadges = [for (final t in _outer) _Badge(tech: t)];

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: Size.square(size),
              painter: _RingsPainter(innerR, outerR),
            ),
          ),
          _Core(ambient: ambient, size: size * 0.34),
          AnimatedBuilder(
            animation: ambient,
            builder: (context, _) {
              final t = ambient.value * 2 * math.pi;
              Offset at(double radius, int i, int count, double speed, double phase) {
                final a = t * speed + phase + i * 2 * math.pi / count;
                // Slightly flattened orbit for depth.
                return Offset(math.cos(a) * radius, math.sin(a) * radius * 0.92);
              }

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  for (var i = 0; i < innerBadges.length; i++)
                    Transform.translate(offset: at(innerR, i, innerBadges.length, 1, 0.4), child: innerBadges[i]),
                  for (var i = 0; i < outerBadges.length; i++)
                    Transform.translate(offset: at(outerR, i, outerBadges.length, -0.6, 0), child: outerBadges[i]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Core extends StatelessWidget {
  const _Core({required this.ambient, required this.size});

  final Animation<double> ambient;
  final double size;

  @override
  Widget build(BuildContext context) {
    final core = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [AppColors.card, AppColors.background],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: size * 0.5),
          BoxShadow(color: AppColors.secondary.withValues(alpha: 0.25), blurRadius: size, spreadRadius: size * 0.1),
        ],
      ),
      alignment: Alignment.center,
      child: FlutterLogo(size: size * 0.48),
    );

    return AnimatedBuilder(
      animation: ambient,
      builder: (context, child) {
        // Gentle float + breathing glow.
        final t = ambient.value * 2 * math.pi * 3;
        return Transform.translate(
          offset: Offset(0, math.sin(t) * 6),
          child: child,
        );
      },
      child: core,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.tech});

  final _Tech tech;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tech.label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.92),
          borderRadius: AppRadius.button,
          border: Border.all(color: tech.color.withValues(alpha: 0.35)),
          boxShadow: [BoxShadow(color: tech.color.withValues(alpha: 0.18), blurRadius: 16)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tech.icon,
            const SizedBox(width: 6),
            Text(
              tech.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter(this.inner, this.outer);

  final double inner;
  final double outer;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final (r, alpha) in [(inner, 0.35), (outer, 0.22)]) {
      final rect = Rect.fromCenter(center: c, width: r * 2, height: r * 2 * 0.92);
      paint.shader = SweepGradient(
        colors: [
          AppColors.highlight.withValues(alpha: alpha),
          AppColors.secondary.withValues(alpha: alpha * 0.2),
          AppColors.highlight.withValues(alpha: alpha),
        ],
      ).createShader(rect);
      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) =>
      old.inner != inner || old.outer != outer;
}
