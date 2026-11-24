import 'package:flutter/widgets.dart';

/// Which illustrative interface to draw when no real screenshots exist.
enum MockupKind { booking, commerce, calling, social }

@immutable
class Project {
  const Project({
    required this.id,
    required this.number,
    required this.name,
    required this.category,
    required this.summary,
    required this.overview,
    required this.contributions,
    required this.keyFeatures,
    required this.technologies,
    required this.accent,
    required this.mockupKind,
    this.screenshots = const [],
    this.screenshotsFramed = false,
    this.isSpotlight = false,
    this.websiteUrl,
  });

  /// URL slug, e.g. `ealzo` → `/projects/ealzo`.
  final String id;
  final String number;
  final String name;
  final String category;

  /// One-line description used on cards.
  final String summary;

  /// Longer description used on the detail page.
  final String overview;
  final List<String> contributions;
  final List<String> keyFeatures;
  final List<String> technologies;
  final Color accent;
  final MockupKind mockupKind;

  /// Asset paths of real app screenshots (portrait, ~9:19.5). When empty the
  /// UI shows a clearly labelled illustrative mockup instead.
  final List<String> screenshots;

  /// True when the screenshots are store-style images that already include
  /// a device frame and caption, so the UI must not wrap them in a phone.
  final bool screenshotsFramed;
  final bool isSpotlight;

  /// Public website for the project, shown as a "Visit website" button on
  /// its detail page.
  final String? websiteUrl;

  bool get hasScreenshots => screenshots.isNotEmpty;
  bool get hasWebsite => websiteUrl != null && websiteUrl!.isNotEmpty;
}
