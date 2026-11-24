import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Animates a heading word by word using a single parent [animation]
/// (0 → 1). Words listed in [highlight] are painted with the brand gradient.
class StaggeredWords extends StatelessWidget {
  const StaggeredWords({
    super.key,
    required this.text,
    required this.animation,
    required this.style,
    this.highlight = const {},
    this.textAlign = TextAlign.start,
  });

  final String text;
  final Animation<double> animation;
  final TextStyle style;
  final Set<String> highlight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    final step = 0.6 / words.length;

    return Semantics(
      header: true,
      label: text,
      child: ExcludeSemantics(
        child: Wrap(
          alignment: switch (textAlign) {
            TextAlign.center => WrapAlignment.center,
            TextAlign.end || TextAlign.right => WrapAlignment.end,
            _ => WrapAlignment.start,
          },
          children: [
            for (var i = 0; i < words.length; i++)
              _Word(
                word: words[i],
                trailingSpace: i < words.length - 1,
                style: style,
                gradient: highlight.contains(words[i]),
                animation: animation.drive(
                  CurveTween(
                    curve: Interval(
                      i * step,
                      (i * step + 0.4).clamp(0, 1),
                      curve: AppCurves.emphasized,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Word extends StatelessWidget {
  const _Word({
    required this.word,
    required this.trailingSpace,
    required this.style,
    required this.gradient,
    required this.animation,
  });

  final String word;
  final bool trailingSpace;
  final TextStyle style;
  final bool gradient;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    Widget text = Text(trailingSpace ? '$word ' : word, style: style);
    if (gradient) {
      text = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: AppColors.textGradient.createShader,
        child: text,
      );
    }
    // Clip so each word rises from behind an invisible baseline.
    return ClipRect(
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.7), end: Offset.zero)
              .animate(animation),
          child: text,
        ),
      ),
    );
  }
}
