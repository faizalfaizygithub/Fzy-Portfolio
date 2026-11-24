import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/responsive/responsive.dart';

/// Fades and slides [child] in the first time it scrolls into view.
///
/// Uses implicit animations (no AnimationController), plays once, and then
/// stops listening for visibility. Respects reduced-motion settings.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.12),
    this.duration = AppDurations.reveal,
    this.threshold = 0.12,
    this.scaleFrom,
  });

  /// Convenience for staggered lists: delay = [index] * [AppDurations.stagger].
  // ignore: prefer_const_constructors_in_immutables
  Reveal.staggered({
    super.key,
    required this.child,
    required int index,
    Duration base = Duration.zero,
    this.offset = const Offset(0, 0.12),
    this.duration = AppDurations.reveal,
    this.threshold = 0.12,
    this.scaleFrom,
  }) : delay = base + AppDurations.stagger * index;

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;
  final double threshold;
  final double? scaleFrom;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  final _key = UniqueKey();
  bool _visible = false;
  bool _triggered = false;
  Timer? _timer;

  void _onVisibility(VisibilityInfo info) {
    if (_triggered || info.visibleFraction < widget.threshold) return;
    _triggered = true;
    if (widget.delay == Duration.zero) {
      if (mounted) setState(() => _visible = true);
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;

    final animated = AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: AppCurves.smooth,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : widget.offset,
        duration: widget.duration,
        curve: AppCurves.emphasized,
        child: widget.scaleFrom == null
            ? widget.child
            : AnimatedScale(
                scale: _visible ? 1 : widget.scaleFrom!,
                duration: widget.duration,
                curve: AppCurves.emphasized,
                child: widget.child,
              ),
      ),
    );

    if (_triggered) return animated;
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: _onVisibility,
      child: animated,
    );
  }
}
