import 'package:flutter/widgets.dart';

/// Spacing, radii, sizes and durations shared across the UI.
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const xxxl = 64.0;
  static const section = 120.0;
  static const sectionMobile = 80.0;
}

abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const pill = 999.0;

  static const card = BorderRadius.all(Radius.circular(lg));
  static const button = BorderRadius.all(Radius.circular(pill));
}

abstract final class AppSizes {
  static const maxContentWidth = 1200.0;
  static const navHeight = 72.0;
  static const navHeightMobile = 64.0;
  static const scrollProgressHeight = 2.0;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 400);
  static const slow = Duration(milliseconds: 700);
  static const reveal = Duration(milliseconds: 800);
  static const scrollTo = Duration(milliseconds: 900);
  static const stagger = Duration(milliseconds: 90);
  static const ambientLoop = Duration(seconds: 12);
}

abstract final class AppCurves {
  static const emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const smooth = Curves.easeOutCubic;
  static const scroll = Curves.easeInOutCubic;
}
