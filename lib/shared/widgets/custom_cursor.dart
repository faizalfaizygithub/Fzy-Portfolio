import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive.dart';

/// Desktop-only cursor effect: a soft glow and a trailing ring that follow
/// the pointer. The system cursor stays visible for accessibility.
///
/// Pointer position lives in a [ValueNotifier], so only the overlay repaints
/// on mouse move — never the page.
class CustomCursorOverlay extends StatefulWidget {
  const CustomCursorOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<CustomCursorOverlay> createState() => _CustomCursorOverlayState();
}

class _CustomCursorOverlayState extends State<CustomCursorOverlay> {
  final _position = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop || context.reduceMotion) return widget.child;

    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.translucent,
      onHover: (e) => _position.value = e.position,
      onExit: (_) => _position.value = null,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<Offset?>(
                valueListenable: _position,
                builder: (context, pos, _) {
                  if (pos == null) return const SizedBox.shrink();
                  return Stack(
                    children: [
                      // Ambient spotlight.
                      Positioned(
                        left: pos.dx - 200,
                        top: pos.dy - 200,
                        child: const _Spotlight(),
                      ),
                      // Trailing ring.
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutCubic,
                        left: pos.dx - 16,
                        top: pos.dy - 16,
                        child: const _Ring(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spotlight extends StatelessWidget {
  const _Spotlight();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: 400,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.07),
                AppColors.primary.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.highlight.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
