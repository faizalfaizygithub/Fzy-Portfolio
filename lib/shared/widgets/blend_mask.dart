import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Paints [child] with [blendMode] against whatever is already painted
/// beneath it — CSS `mix-blend-mode`. With [BlendMode.difference] and white
/// content, text turns black over light areas and white over dark ones.
class BlendMask extends SingleChildRenderObjectWidget {
  const BlendMask({super.key, required this.blendMode, super.child});

  final BlendMode blendMode;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderBlendMask(blendMode);

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject.blendMode = blendMode;
  }
}

class RenderBlendMask extends RenderProxyBox {
  RenderBlendMask(this._blendMode);

  BlendMode _blendMode;
  set blendMode(BlendMode value) {
    if (value == _blendMode) return;
    _blendMode = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    context.canvas.saveLayer(offset & size, Paint()..blendMode = _blendMode);
    super.paint(context, offset);
    context.canvas.restore();
  }
}
