import 'package:flutter/widgets.dart';

/// Computes a value from this widget's position in the viewport whenever
/// [controller] scrolls, and rebuilds only when that value changes.
///
/// [compute] receives the widget's top (global y), its height and the
/// viewport height.
class ScrollAware<T> extends StatefulWidget {
  const ScrollAware({
    super.key,
    required this.controller,
    required this.compute,
    required this.initial,
    required this.builder,
  });

  final ScrollController controller;
  final T Function(double top, double height, double viewport) compute;
  final T initial;
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<ScrollAware<T>> createState() => _ScrollAwareState<T>();
}

class _ScrollAwareState<T> extends State<ScrollAware<T>> {
  late T _value = widget.initial;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(covariant ScrollAware<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
  }

  void _update() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final viewport = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    final next = widget.compute(top, box.size.height, viewport);
    if (next != _value) setState(() => _value = next);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value);
}
