import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Circular text that slowly rotates around a centre icon.
class RotatingBadge extends StatefulWidget {
  const RotatingBadge({
    super.key,
    required this.text,
    this.size = 132,
    this.background = AppColors.cream,
    this.foreground = AppColors.textInverse,
    this.icon = Icons.north_east_rounded,
  });

  final String text;
  final double size;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  State<RotatingBadge> createState() => _RotatingBadgeState();
}

class _RotatingBadgeState extends State<RotatingBadge>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.mono(
      TextStyle(
        fontSize: widget.size * 0.085,
        fontWeight: FontWeight.w600,
        color: widget.foreground,
        letterSpacing: 0,
      ),
    );
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.background,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _c,
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: _CircleTextPainter(widget.text, style),
                ),
              ),
              Icon(
                widget.icon,
                color: widget.foreground,
                size: widget.size * 0.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleTextPainter extends CustomPainter {
  _CircleTextPainter(this.text, this.style);

  final String text;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - (style.fontSize ?? 10) * 1.4;
    final chars = text.split('');
    final step = 2 * math.pi / chars.length;
    canvas.translate(size.width / 2, size.height / 2);
    for (var i = 0; i < chars.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: chars[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.rotate(i * step);
      tp.paint(canvas, Offset(-tp.width / 2, -radius - tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CircleTextPainter old) => old.text != text;
}
