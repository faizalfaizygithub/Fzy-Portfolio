import 'package:flutter/material.dart';

/// Tracks pointer hover and keyboard focus so cards and buttons can share one
/// "active" state. Rebuilds only this subtree when hover changes.
class HoverBuilder extends StatefulWidget {
  const HoverBuilder({
    super.key,
    required this.builder,
    this.onTap,
    this.cursor = SystemMouseCursors.click,
    this.semanticLabel,
  });

  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final MouseCursor cursor;
  final String? semanticLabel;

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _hovered = false;
  bool _focused = false;

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _focused;
    final content = MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : widget.cursor,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: widget.builder(context, active),
    );

    if (widget.onTap == null) return content;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap!();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: content,
        ),
      ),
    );
  }
}
