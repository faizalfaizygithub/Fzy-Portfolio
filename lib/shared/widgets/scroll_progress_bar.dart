import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Thin gradient bar showing how far down the page the reader is.
/// Listens to the controller directly so only this bar repaints on scroll.
class ScrollProgressBar extends StatelessWidget {
  const ScrollProgressBar({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: AppSizes.scrollProgressHeight,
        width: double.infinity,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            var progress = 0.0;
            if (controller.hasClients &&
                controller.position.hasContentDimensions &&
                controller.position.maxScrollExtent > 0) {
              progress = (controller.offset / controller.position.maxScrollExtent)
                  .clamp(0.0, 1.0);
            }
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.textGradient,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary, blurRadius: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
