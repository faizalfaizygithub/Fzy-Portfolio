import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import 'scroll_select.dart';

/// Paragraph whose words light up one by one as the page scrolls
/// (from 16% to full opacity), tied directly to scroll position.
class ScrubText extends StatelessWidget {
  const ScrubText(
    this.text, {
    super.key,
    required this.style,
    this.start = 0.85,
    this.end = 0.45,
    this.dimOpacity = 0.16,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle style;

  /// Viewport fractions: words start lighting when the top reaches [start]
  /// and finish when the bottom reaches [end].
  final double start;
  final double end;
  final double dimOpacity;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) {
      return Text(text, style: style, textAlign: textAlign);
    }
    final words = text.split(' ');
    final color = style.color ?? Colors.white;

    return ScrollSelect<double>(
      initial: 0,
      select: (m) => quantize(m.range(start, end), 200),
      builder: (context, progress, _) {
        // Each word fades over a short window; windows overlap slightly.
        final n = words.length;
        return Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < n; i++)
                TextSpan(
                  text: i == n - 1 ? words[i] : '${words[i]} ',
                  style: TextStyle(
                    color: color.withValues(
                      alpha:
                          dimOpacity +
                          (1 - dimOpacity) *
                              ((progress * (n + 2) - i) / 3).clamp(0.0, 1.0),
                    ),
                  ),
                ),
            ],
          ),
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}
