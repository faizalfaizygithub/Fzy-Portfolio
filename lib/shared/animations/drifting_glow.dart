import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/responsive/responsive.dart';
import '../../core/widgets/ambient_glow.dart';

/// Decorative glow that slowly drifts between two alignments while visible.
/// Implicit animation only; pauses when off-screen or with reduced motion.
class DriftingGlow extends StatefulWidget {
  const DriftingGlow({
    super.key,
    required this.color,
    required this.size,
    this.from = const Alignment(-1, -0.6),
    this.to = const Alignment(-0.4, 0.4),
    this.opacity = 0.22,
    this.period = const Duration(seconds: 9),
  });

  final Color color;
  final double size;
  final Alignment from;
  final Alignment to;
  final double opacity;
  final Duration period;

  @override
  State<DriftingGlow> createState() => _DriftingGlowState();
}

class _DriftingGlowState extends State<DriftingGlow> {
  final _key = UniqueKey();
  bool _atEnd = false;
  bool _visible = false;

  void _toggle() {
    if (mounted && _visible) setState(() => _atEnd = !_atEnd);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0;
        if (visible == _visible) return;
        _visible = visible;
        if (visible && !reduce) _toggle();
      },
      child: AnimatedAlign(
        alignment: _atEnd ? widget.to : widget.from,
        duration: widget.period,
        curve: Curves.easeInOutSine,
        onEnd: reduce ? null : _toggle,
        child: AmbientGlow(
          color: widget.color,
          size: widget.size,
          opacity: widget.opacity,
        ),
      ),
    );
  }
}
