import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/marquee.dart';

class _Tech {
  const _Tech(this.name, {this.icon, this.tile});
  final String name;
  final IconData? icon;

  /// Two-letter tile used when there's no brand icon.
  final String? tile;
}

/// Two rows of technologies drifting in opposite directions, with soft
/// fades at the edges.
class TechMarquee extends StatelessWidget {
  const TechMarquee({super.key});

  static final _rowA = [
    _Tech('Flutter', icon: Icons.flutter_dash_rounded),
    _Tech('Dart', tile: 'Dt'),
    _Tech('Firebase', icon: FontAwesomeIcons.fire.data),
    _Tech('Provider', tile: 'Pv'),
    _Tech('REST APIs', tile: '{}'),
    _Tech('WebSockets', tile: 'Ws'),
    _Tech('Agora SDK', tile: 'Ag'),
    _Tech('Clean Architecture', tile: 'CA'),
  ];

  static final _rowB = [
    _Tech('Razorpay', tile: 'Rp'),
    _Tech('Cashfree', tile: 'Cf'),
    _Tech('Hive', tile: 'Hv'),
    _Tech('SQLite', tile: 'Sq'),
    _Tech('Figma', icon: FontAwesomeIcons.figma.data),
    _Tech('Git', icon: FontAwesomeIcons.gitAlt.data),
    _Tech('Android', icon: FontAwesomeIcons.android.data),
    _Tech('iOS', icon: FontAwesomeIcons.apple.data),
    _Tech('Play Console', icon: FontAwesomeIcons.googlePlay.data),
  ];

  @override
  Widget build(BuildContext context) {
    final gap = fluid(context, 40, 72);
    Widget row(List<_Tech> items) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final t in items)
          Padding(
            padding: EdgeInsets.only(right: gap),
            child: _TechItem(tech: t),
          ),
      ],
    );

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(vertical: fluid(context, 28, 50)),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => LinearGradient(
          colors: const [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0, 160 / rect.width, 1 - 160 / rect.width, 1],
        ).createShader(rect),
        child: Column(
          children: [
            Marquee(speed: 42, child: row(_rowA)),
            SizedBox(height: fluid(context, 18, 28)),
            Marquee(speed: 36, reverse: true, child: row(_rowB)),
          ],
        ),
      ),
    );
  }
}

class _TechItem extends StatelessWidget {
  const _TechItem({required this.tech});

  final _Tech tech;

  @override
  Widget build(BuildContext context) {
    final size = fluid(context, 28, 34);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: tech.icon != null
              ? Alignment.center
              : Alignment.bottomRight,
          padding: tech.icon != null ? null : const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.raised,
            borderRadius: BorderRadius.circular(size * 0.22),
            border: Border.all(color: AppColors.border),
          ),
          child: tech.icon != null
              ? Icon(tech.icon, size: size * 0.5, color: AppColors.textPrimary)
              : Text(
                  tech.tile!,
                  style: AppTypography.label(
                    TextStyle(
                      fontSize: size * 0.32,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
        ),
        SizedBox(width: size * 0.45),
        Text(
          tech.name,
          style: AppTypography.heading(
            TextStyle(
              fontSize: fluid(context, 19, 23),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
