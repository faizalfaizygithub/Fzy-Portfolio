import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';

/// Infinite horizontal ticker. [child] is repeated until it fills the width
/// and scrolls at [speed] logical pixels per second. Hovering slows it down.
///
/// With reduced motion the content is shown once and can be scrolled sideways.
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.child,
    this.speed = 48,
    this.reverse = false,
    this.gap = 0,
  });

  final Widget child;
  final double speed;
  final bool reverse;
  final double gap;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  final _groupKey = GlobalKey();
  final _offset = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;
  double _groupWidth = 0;
  double _speedFactor = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final box = _groupKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final width = box.size.width + widget.gap;
    if (width != _groupWidth) setState(() => _groupWidth = width);
    if (!_ticker.isActive && !context.reduceMotion) _ticker.start();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_groupWidth <= 0 || dt <= 0 || dt > 0.1) return;
    final next = _offset.value + widget.speed * _speedFactor * dt;
    _offset.value = next % _groupWidth;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = Padding(
      padding: EdgeInsets.only(right: widget.gap),
      child: widget.child,
    );
    if (context.reduceMotion) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: widget.child,
      );
    }

    return MouseRegion(
      onEnter: (_) => _speedFactor = 0.35,
      onExit: (_) => _speedFactor = 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copies = _groupWidth <= 0
              ? 2
              : (constraints.maxWidth / _groupWidth).ceil() + 2;
          return SizedBox(
            width: constraints.maxWidth,
            child: UnconstrainedBox(
              alignment: Alignment.centerLeft,
              constrainedAxis: Axis.vertical,
              clipBehavior: Clip.hardEdge,
              child: ValueListenableBuilder<double>(
                valueListenable: _offset,
                builder: (context, offset, child) => Transform.translate(
                  offset: Offset(
                    widget.reverse ? offset - _groupWidth : -offset,
                    0,
                  ),
                  child: child,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KeyedSubtree(key: _groupKey, child: group),
                    for (var i = 1; i < copies; i++)
                      ExcludeSemantics(child: group),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
