import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/responsive/responsive.dart';

/// Pulls [child] toward the pointer while hovered, then springs back.
class Magnetic extends StatefulWidget {
  const Magnetic({super.key, required this.child, this.strength = 0.3});

  final Widget child;

  /// Fraction of the pointer's distance from centre that the child follows.
  final double strength;

  @override
  State<Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<Magnetic> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion || !context.isDesktop) return widget.child;
    return MouseRegion(
      opaque: false,
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final centre = box.size.center(Offset.zero);
        setState(() => _offset = (e.localPosition - centre) * widget.strength);
      },
      onExit: (_) => setState(() => _offset = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(end: _offset),
        duration: _offset == Offset.zero
            ? const Duration(milliseconds: 700)
            : const Duration(milliseconds: 250),
        curve: _offset == Offset.zero ? AppCurves.spring : AppCurves.out,
        builder: (context, value, child) =>
            Transform.translate(offset: value, child: child),
        child: widget.child,
      ),
    );
  }
}
