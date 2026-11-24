import 'package:flutter/widgets.dart';

enum ScreenType { mobile, tablet, desktop }

abstract final class Breakpoints {
  static const tablet = 720.0;
  static const desktop = 1080.0;
}

/// Width-based layout helpers. Uses [MediaQuery.sizeOf] so widgets only
/// rebuild when the size changes, not on every MediaQuery change.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenType get screenType => screenTypeFor(screenWidth);

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;

  /// Picks a value for the current screen type, falling back to the next
  /// smaller size when one isn't given.
  T responsive<T>({required T mobile, T? tablet, T? desktop}) =>
      switch (screenType) {
        ScreenType.desktop => desktop ?? tablet ?? mobile,
        ScreenType.tablet => tablet ?? mobile,
        ScreenType.mobile => mobile,
      };

  double get horizontalPadding =>
      responsive(mobile: 20.0, tablet: 40.0, desktop: 64.0);

  /// True when the OS asks for reduced motion (`prefers-reduced-motion` on web).
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}

ScreenType screenTypeFor(double width) {
  if (width >= Breakpoints.desktop) return ScreenType.desktop;
  if (width >= Breakpoints.tablet) return ScreenType.tablet;
  return ScreenType.mobile;
}
