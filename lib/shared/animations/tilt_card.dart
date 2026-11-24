import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/responsive/responsive.dart';

/// Tilts its child in 3D toward the pointer. Mouse only — touch devices and
/// reduced-motion users get a flat card.
class TiltCard extends StatefulWidget {
  const TiltCard({super.key, required this.builder, this.maxTilt = 0.12});

  final Widget Function(BuildContext context, bool hovered) builder;
  final double maxTilt;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  Offset _tilt = Offset.zero; // -1..1 on each axis.
  bool _hovered = false;

  void _onHover(PointerEvent e, Size size) {
    final dx = (e.localPosition.dx / size.width) * 2 - 1;
    final dy = (e.localPosition.dy / size.height) * 2 - 1;
    setState(() {
      _hovered = true;
      _tilt = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion || !context.isDesktop) {
      return widget.builder(context, false);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight.isFinite ? constraints.maxHeight : 300);
        return MouseRegion(
          onHover: (e) {
            final box = context.findRenderObject() as RenderBox?;
            _onHover(e, box?.size ?? size);
          },
          onExit: (_) => setState(() {
            _hovered = false;
            _tilt = Offset.zero;
          }),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(end: _tilt),
            duration: AppDurations.fast,
            curve: AppCurves.smooth,
            builder: (context, tilt, child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(-tilt.dy * widget.maxTilt)
                ..rotateY(tilt.dx * widget.maxTilt),
              child: child,
            ),
            child: widget.builder(context, _hovered),
          ),
        );
      },
    );
  }
}
