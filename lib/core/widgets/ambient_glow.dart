import 'package:flutter/material.dart';

/// Soft radial light used for ambient background lighting. Painted with a
/// radial gradient instead of a blur filter, which is far cheaper on web.
class AmbientGlow extends StatelessWidget {
  const AmbientGlow({
    super.key,
    required this.color,
    required this.size,
    this.opacity = 0.35,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity * 0.35),
                color.withValues(alpha: 0),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
      ),
    );
  }
}
