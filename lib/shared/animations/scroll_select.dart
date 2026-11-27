import 'package:flutter/widgets.dart';

/// Where a widget sits relative to the viewport of its nearest [Scrollable].
@immutable
class ViewportMetrics {
  const ViewportMetrics({
    required this.top,
    required this.height,
    required this.viewport,
  });

  /// Distance from the top of the viewport to the top of the widget.
  /// Negative once the widget's top has scrolled past.
  final double top;
  final double height;
  final double viewport;

  double get bottom => top + height;

  /// 0 when the widget's top enters at the bottom of the viewport, 1 when its
  /// bottom leaves at the top.
  double get passThrough =>
      ((viewport - top) / (viewport + height)).clamp(0.0, 1.0);

  /// Progress between "top reaches [start]·viewport" (0) and
  /// "bottom reaches [end]·viewport" (1) — GSAP ScrollTrigger semantics.
  double range(double start, double end) {
    final from = viewport * start;
    final to = viewport * end - height;
    final span = from - to;
    if (span <= 0) return top <= from ? 1 : 0;
    return ((from - top) / span).clamp(0.0, 1.0);
  }
}

/// Maps this widget's scroll position to a value with [select] and rebuilds
/// only when that value changes. Listens to the nearest [Scrollable], so it
/// works on any scrolling page without passing a controller around.
class ScrollSelect<T> extends StatefulWidget {
  const ScrollSelect({
    super.key,
    required this.select,
    required this.initial,
    required this.builder,
    this.child,
  });

  final T Function(ViewportMetrics metrics) select;
  final T initial;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  @override
  State<ScrollSelect<T>> createState() => _ScrollSelectState<T>();
}

class _ScrollSelectState<T> extends State<ScrollSelect<T>> {
  late T _value = widget.initial;
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      _position?.removeListener(_update);
      _position = next?..addListener(_update);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  void _update() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final viewport = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    final next = widget.select(
      ViewportMetrics(top: top, height: box.size.height, viewport: viewport),
    );
    if (next != _value) setState(() => _value = next);
  }

  @override
  void dispose() {
    _position?.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value, widget.child);
}

/// Rounds scroll progress so rebuilds happen at most ~[steps] times across
/// the whole range.
double quantize(double value, [int steps = 400]) =>
    (value * steps).roundToDouble() / steps;

/// A section that "pins" its content to the viewport while the page scrolls
/// through [scrollLength] extra pixels — CSS `position: sticky` driven by
/// scroll. [builder] receives progress from 0 to 1.
class PinnedSection extends StatelessWidget {
  const PinnedSection({
    super.key,
    required this.scrollLength,
    required this.builder,
    this.viewportHeight,
  });

  final double scrollLength;
  final double? viewportHeight;
  final Widget Function(BuildContext context, double progress) builder;

  @override
  Widget build(BuildContext context) {
    final vh = viewportHeight ?? MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: vh + scrollLength,
      child: ScrollSelect<double>(
        initial: 0,
        select: (m) => (-m.top).clamp(0.0, scrollLength).roundToDouble(),
        builder: (context, offset, _) => Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: offset,
              left: 0,
              right: 0,
              height: vh,
              child: builder(
                context,
                scrollLength == 0 ? 0 : offset / scrollLength,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
