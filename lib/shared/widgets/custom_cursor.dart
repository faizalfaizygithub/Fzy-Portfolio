import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive.dart';
import 'blend_mask.dart';

/// Desktop-only cursor: a small dot that sticks to the pointer and a ring
/// that trails behind it with easing. Both use a difference blend, so they
/// read on the white hero and the dark page alike. The system cursor stays
/// visible for accessibility.
class CustomCursorOverlay extends StatefulWidget {
  const CustomCursorOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<CustomCursorOverlay> createState() => _CustomCursorOverlayState();
}

class _CustomCursorOverlayState extends State<CustomCursorOverlay>
    with SingleTickerProviderStateMixin {
  final _dot = ValueNotifier<Offset?>(null);
  final _ring = ValueNotifier<Offset?>(null);
  late final Ticker _ticker = createTicker(_tick);

  void _tick(Duration _) {
    final target = _dot.value;
    final current = _ring.value;
    if (target == null) return;
    if (current == null) {
      _ring.value = target;
      return;
    }
    final next = Offset.lerp(current, target, 0.16)!;
    if ((next - target).distance < 0.1) {
      _ring.value = target;
      _ticker.stop();
    } else {
      _ring.value = next;
    }
  }

  void _move(Offset p) {
    _dot.value = p;
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _dot.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop || context.reduceMotion) return widget.child;

    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.translucent,
      onHover: (e) => _move(e.position),
      onExit: (_) {
        _dot.value = null;
        _ring.value = null;
      },
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: BlendMask(
                blendMode: BlendMode.difference,
                child: Stack(
                  children: [
                    ValueListenableBuilder<Offset?>(
                      valueListenable: _ring,
                      builder: (context, p, _) => p == null
                          ? const SizedBox.shrink()
                          : Positioned(
                              left: p.dx - 18,
                              top: p.dy - 18,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.paper,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    ValueListenableBuilder<Offset?>(
                      valueListenable: _dot,
                      builder: (context, p, _) => p == null
                          ? const SizedBox.shrink()
                          : Positioned(
                              left: p.dx - 3,
                              top: p.dy - 3,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.paper,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
