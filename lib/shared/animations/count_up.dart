import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/responsive/responsive.dart';

/// Counts from 0 to [value] the first time it scrolls into view.
class CountUp extends StatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.decimals = 0,
    this.padLeft = 0,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1600),
  });

  final double value;
  final TextStyle style;
  final int decimals;

  /// Zero-pad to this many integer digits (e.g. 5 → "05").
  final int padLeft;
  final String suffix;
  final Duration duration;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> {
  final _key = UniqueKey();
  bool _go = false;

  String _format(double v) {
    var s = v.toStringAsFixed(widget.decimals);
    if (widget.padLeft > 0) {
      final parts = s.split('.');
      parts[0] = parts[0].padLeft(widget.padLeft, '0');
      s = parts.join('.');
    }
    return '$s${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) {
      return Text(_format(widget.value), style: widget.style);
    }
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        if (!_go && info.visibleFraction > 0.4 && mounted) {
          setState(() => _go = true);
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _go ? widget.value : 0),
        duration: widget.duration,
        curve: AppCurves.expoOut,
        builder: (context, v, _) => Text(_format(v), style: widget.style),
      ),
    );
  }
}
