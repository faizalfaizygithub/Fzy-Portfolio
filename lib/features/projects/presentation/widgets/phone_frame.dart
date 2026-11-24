import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// A stylised phone body. The [screen] is laid out at a fixed design size
/// (300 × 650) and scaled to fit, so mockups look identical at any width.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({
    super.key,
    required this.screen,
    this.width = 240,
    this.accent = AppColors.primary,
    this.elevated = true,
  });

  static const designSize = Size(300, 650);
  static const aspectRatio = 300 / 650;

  final Widget screen;
  final double width;
  final Color accent;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final height = width / aspectRatio;
    final radius = width * 0.15;
    final bezel = width * 0.035;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF34344C),
              const Color(0xFF16162A),
              accent.withValues(alpha: 0.45),
            ],
          ),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.22),
                    blurRadius: width * 0.35,
                    offset: Offset(0, width * 0.12),
                  ),
                  const BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 30,
                    offset: Offset(0, 18),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(bezel),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - bezel),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox.fromSize(size: designSize, child: screen),
                ),
                // Dynamic-island style notch.
                Align(
                  alignment: const Alignment(0, -0.975),
                  child: Container(
                    width: width * 0.28,
                    height: width * 0.07,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(width),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A store-style screenshot that already contains its own device frame.
/// Sized like [PhoneFrame] so both can be used interchangeably.
class FramedScreenshot extends StatelessWidget {
  const FramedScreenshot(
    this.assetPath, {
    super.key,
    this.width = 240,
    this.accent = AppColors.primary,
    this.semanticLabel,
  });

  final String assetPath;
  final double width;
  final Color accent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(width * 0.09);
    return Container(
      width: width,
      height: width / PhoneFrame.aspectRatio,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: width * 0.35,
            offset: Offset(0, width * 0.12),
          ),
          const BoxShadow(color: Color(0x99000000), blurRadius: 30, offset: Offset(0, 18)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          semanticLabel: semanticLabel,
          cacheWidth: 720,
          errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.card),
        ),
      ),
    );
  }
}

/// Shows a real screenshot inside the phone screen.
class ScreenshotScreen extends StatelessWidget {
  const ScreenshotScreen(this.assetPath, {super.key, this.semanticLabel});

  final String assetPath;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      semanticLabel: semanticLabel,
      // Decode at roughly display size to save memory.
      cacheWidth: 600,
      errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.card),
    );
  }
}
