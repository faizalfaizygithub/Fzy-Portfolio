import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'app.dart';

void main() {
  // Clean URLs (/projects/ealzo instead of /#/projects/ealzo). Hosting must
  // rewrite unknown paths to index.html — see firebase.json / vercel.json.
  usePathUrlStrategy();

  // Scroll-triggered reveals react faster than the 500ms default.
  VisibilityDetectorController.instance.updateInterval = const Duration(
    milliseconds: 80,
  );

  runApp(const PortfolioApp());
}
