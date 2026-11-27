import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';

/// Text that rolls up to reveal a copy of itself when [active] — the
/// classic studio-site link hover.
class RollText extends StatelessWidget {
  const RollText(
    this.text, {
    super.key,
    required this.style,
    required this.active,
  });

  final String text;
  final TextStyle style;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final label = Text(text, style: style, maxLines: 1);
    if (MediaQuery.disableAnimationsOf(context)) return label;
    return ClipRect(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: active ? 1 : 0),
        duration: const Duration(milliseconds: 520),
        curve: AppCurves.inOut,
        builder: (context, t, _) => Stack(
          children: [
            FractionalTranslation(translation: Offset(0, -t), child: label),
            Positioned.fill(
              child: FractionalTranslation(
                translation: Offset(0, 1 - t),
                child: ExcludeSemantics(child: label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
