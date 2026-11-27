import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/responsive/responsive.dart';

/// Masked line reveal: each line slides up from behind its own clip, one
/// after another (GSAP SplitText `lines` + `mask`).
///
/// Plays when scrolled into view, or — if [play] is given — when [play]
/// becomes true (used by the hero after the preloader).
class LineReveal extends StatefulWidget {
  const LineReveal({
    super.key,
    required this.lines,
    required this.style,
    this.play,
    this.delay = Duration.zero,
    this.stagger = const Duration(milliseconds: 90),
    this.duration = const Duration(milliseconds: 1000),
    this.textAlign = TextAlign.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.lineColors,
  });

  final List<String> lines;
  final TextStyle style;
  final bool? play;
  final Duration delay;
  final Duration stagger;
  final Duration duration;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  /// Optional per-line colors (e.g. a muted second line).
  final List<Color?>? lineColors;

  @override
  State<LineReveal> createState() => _LineRevealState();
}

class _LineRevealState extends State<LineReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _key = UniqueKey();
  bool _triggered = false;
  Timer? _timer;

  int get _count => widget.lines.length;

  @override
  void initState() {
    super.initState();
    final total = widget.duration + widget.stagger * (_count - 1);
    _controller = AnimationController(vsync: this, duration: total);
    if (widget.play == true) _start();
  }

  @override
  void didUpdateWidget(covariant LineReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play == true && oldWidget.play != true) _start();
  }

  void _start() {
    if (_triggered) return;
    _triggered = true;
    _timer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _line(int i) {
    final color = widget.lineColors != null && i < widget.lineColors!.length
        ? widget.lineColors![i]
        : null;
    final text = Text(
      widget.lines[i],
      style: color == null ? widget.style : widget.style.copyWith(color: color),
      textAlign: widget.textAlign,
    );
    if (context.reduceMotion) return text;

    final total = _controller.duration!.inMicroseconds;
    final start = (widget.stagger * i).inMicroseconds / total;
    final end = (widget.stagger * i + widget.duration).inMicroseconds / total;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end.clamp(0, 1), curve: AppCurves.power4Out),
    );
    final pad = (widget.style.fontSize ?? 16) * 0.12;

    return ClipRect(
      child: Padding(
        padding: EdgeInsets.only(bottom: pad),
        child: AnimatedBuilder(
          animation: curve,
          child: text,
          builder: (context, child) => FractionalTranslation(
            translation: Offset(0, 1.15 * (1 - curve.value)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [for (var i = 0; i < _count; i++) _line(i)],
    );
    if (context.reduceMotion || widget.play != null || _triggered) {
      return column;
    }
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.15) _start();
      },
      child: column,
    );
  }
}
