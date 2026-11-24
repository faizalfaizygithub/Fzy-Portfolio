import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/widgets/ambient_glow.dart';
import '../../domain/project.dart';
import 'mock_screens.dart';

/// Overlapping phones for project cards. On hover the side phones fan out
/// and the centre phone rises, revealing more of each screen.
class PhoneComposition extends StatelessWidget {
  const PhoneComposition({
    super.key,
    required this.project,
    required this.height,
    this.hovered = false,
    this.phoneCount = 3,
  });

  final Project project;
  final double height;
  final bool hovered;
  final int phoneCount;

  @override
  Widget build(BuildContext context) {
    final mainWidth = height * 0.82 * (300 / 650);
    final sideWidth = mainWidth * 0.84;
    final spread = mainWidth * (hovered ? 0.74 : 0.6);

    Widget phone(int variant, double width, double dx, double dy, double angle) {
      return AnimatedContainer(
        duration: AppDurations.slow,
        curve: AppCurves.emphasized,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..translateByDouble(dx, dy, 0, 1)
          ..rotateZ(angle),
        child: buildProjectPhone(project, variant, width: width),
      );
    }

    final tilt = hovered ? 0.09 : 0.06;
    // With two phones the group leans left; shift it back to centre.
    final shift = phoneCount == 2 ? spread / 2 : 0.0;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedScale(
            duration: AppDurations.slow,
            scale: hovered ? 1.15 : 1,
            child: AmbientGlow(
              color: project.accent,
              size: height * 1.1,
              opacity: 0.28,
            ),
          ),
          if (phoneCount >= 3)
            phone(2, sideWidth, spread + shift, height * 0.06, tilt),
          if (phoneCount >= 2)
            phone(1, sideWidth, -spread + shift, height * 0.06, -tilt),
          phone(0, mainWidth, shift, hovered ? -height * 0.03 : 0, 0),
        ],
      ),
    );
  }
}
