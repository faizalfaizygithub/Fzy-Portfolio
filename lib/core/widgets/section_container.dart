import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../responsive/responsive.dart';

/// Centers content at [AppSizes.maxContentWidth] with responsive padding.
class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.child,
    this.verticalPadding,
    this.background,
  });

  final Widget child;
  final double? verticalPadding;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final double vertical =
        verticalPadding ??
        context.responsive<double>(
          mobile: AppSpacing.sectionMobile,
          desktop: AppSpacing.section,
        );

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalPadding,
        vertical: vertical,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          // Always span the full content width so sections share one grid.
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );

    if (background == null) return content;
    return Stack(
      children: [
        Positioned.fill(child: IgnorePointer(child: background!)),
        content,
      ],
    );
  }
}
