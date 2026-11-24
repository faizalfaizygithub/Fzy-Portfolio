import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/theme/app_typography.dart';

/// Editor-style card that "types" a short Dart snippet as [progress] goes
/// from 0 to 1.
class CodeSnippetCard extends StatelessWidget {
  const CodeSnippetCard({super.key, required this.progress, this.width = 340});

  final Animation<double> progress;
  final double width;

  static const _keyword = Color(0xFFC792EA);
  static const _type = Color(0xFF82AAFF);
  static const _string = Color(0xFFC3E88D);
  static const _plain = Color(0xFFE4E4F0);
  static const _muted = Color(0xFF6E6E86);
  static const _accent = AppColors.highlight;

  /// (text, color) tokens. `\n` tokens break lines.
  static const _tokens = <(String, Color)>[
    ('class ', _keyword), ('Faisal ', _type), ('extends ', _keyword), ('Developer', _type), (' {\n', _plain),
    ('  final ', _keyword), ('stack ', _plain), ('= [', _plain), ("'Flutter'", _string), (', ', _plain), ("'Dart'", _string), ('];\n', _plain),
    ('\n', _plain),
    ('  @override\n', _muted),
    ('  Widget ', _type), ('build', _accent), ('(context) {\n', _plain),
    ('    return ', _keyword), ('CleanApp', _type), ('(\n', _plain),
    ('      platforms: ', _plain), ('[android, iOS]', _string), (',\n', _plain),
    ('      realtime: ', _plain), ('true', _keyword), (',\n', _plain),
    ('    );\n', _plain),
    ('  }\n', _plain),
    ('}', _plain),
  ];

  static final _totalChars = _tokens.fold<int>(0, (sum, t) => sum + t.$1.length);

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.mono(const TextStyle(fontSize: 12.5, height: 1.65, color: _plain));

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20)),
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 40),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Window chrome.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                for (final c in const [Color(0xFFFF5F57), Color(0xFFFEBC2E), Color(0xFF28C840)])
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                const SizedBox(width: AppSpacing.sm),
                Text('faisal.dart', style: base.copyWith(fontSize: 11.5, color: _muted)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                final visible = (progress.value * _totalChars).round();
                return Stack(
                  children: [
                    // Invisible full text reserves the final size so the
                    // card doesn't grow while typing.
                    Opacity(opacity: 0, child: Text.rich(_span(base, _totalChars, false))),
                    Text.rich(_span(base, visible, visible < _totalChars)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _span(TextStyle base, int visible, bool caret) {
    final spans = <InlineSpan>[];
    var remaining = visible;
    for (final (text, color) in _tokens) {
      if (remaining <= 0) break;
      final part = text.length <= remaining ? text : text.substring(0, remaining);
      remaining -= part.length;
      spans.add(TextSpan(text: part, style: TextStyle(color: color)));
    }
    if (caret) {
      // Drawn as a box: block glyphs aren't in every font.
      spans.add(const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SizedBox(
          width: 7,
          height: 15,
          child: ColoredBox(color: _accent),
        ),
      ));
    }
    return TextSpan(style: base, children: spans);
  }
}
