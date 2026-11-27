import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../shared/models/skill.dart';

/// Skills from the CV, grouped by category.
abstract final class SkillsData {
  static final categories = <SkillCategory>[
    SkillCategory('Languages & Frameworks', Icons.code_rounded, [
      Skill(
        'Dart',
        Icons.data_object_rounded,
        'Type-safe, null-safe language behind every app I build.',
      ),
      Skill(
        'Flutter',
        Icons.flutter_dash_rounded,
        'Cross-platform UI toolkit for Android, iOS and web.',
      ),
    ]),
    SkillCategory('State Management', Icons.account_tree_rounded, [
      Skill(
        'Provider',
        Icons.hub_rounded,
        'Dependency injection and app-wide state.',
      ),
      Skill(
        'ChangeNotifier',
        Icons.notifications_active_outlined,
        'Lean, reactive state with targeted rebuilds.',
      ),
    ]),
    SkillCategory('Architecture', Icons.layers_rounded, [
      Skill(
        'Clean Architecture',
        Icons.layers_rounded,
        'Separated data, domain and presentation layers.',
      ),
      Skill(
        'Repository Pattern',
        Icons.storage_rounded,
        'One clean interface over remote and local data.',
      ),
      Skill(
        'SOLID Principles',
        Icons.view_module_rounded,
        'Small, testable, single-purpose components.',
      ),
    ]),
    SkillCategory('Backend & APIs', Icons.api_rounded, [
      Skill(
        'REST API Integration',
        Icons.api_rounded,
        'Reliable networking, error handling and auth flows.',
      ),
      Skill(
        'JSON Serialization',
        Icons.data_array_rounded,
        'Typed models for safe API data parsing.',
      ),
      Skill(
        'WebSockets',
        Icons.sync_alt_rounded,
        'Live, bidirectional data for real-time features.',
      ),
    ]),
    SkillCategory('Firebase', FontAwesomeIcons.fire.data, [
      Skill(
        'Firebase Authentication',
        Icons.verified_user_outlined,
        'Secure sign-in and session handling.',
      ),
      Skill(
        'Cloud Firestore',
        Icons.cloud_outlined,
        'Real-time NoSQL data sync.',
      ),
      Skill(
        'Firebase Cloud Messaging',
        Icons.notifications_none_rounded,
        'Push notifications and call alerts.',
      ),
      Skill(
        'Crashlytics',
        Icons.bug_report_outlined,
        'Crash reporting to keep releases stable.',
      ),
    ]),
    SkillCategory('Real-Time Communication', Icons.videocam_rounded, [
      Skill(
        'Agora SDK',
        Icons.podcasts_rounded,
        'Real-time engine for in-app calling.',
      ),
      Skill(
        'Audio Calling',
        Icons.call_rounded,
        'Voice calls with call notifications.',
      ),
      Skill(
        'Video Calling',
        Icons.videocam_rounded,
        'Face-to-face video calls inside the app.',
      ),
    ]),
    SkillCategory('Payments', Icons.payments_rounded, [
      Skill(
        'Razorpay',
        Icons.currency_rupee_rounded,
        'Checkout and appointment payment flows.',
      ),
      Skill(
        'Cashfree',
        Icons.account_balance_wallet_outlined,
        'Payment gateway integration.',
      ),
    ]),
    SkillCategory('Local Storage', Icons.sd_storage_rounded, [
      Skill(
        'SharedPreferences',
        Icons.tune_rounded,
        'Lightweight key-value settings.',
      ),
      Skill(
        'SQLite',
        Icons.table_chart_outlined,
        'Structured relational on-device data.',
      ),
      Skill(
        'Hive',
        Icons.hive_outlined,
        'Fast NoSQL storage for offline data.',
      ),
    ]),
    SkillCategory('UI / UX', Icons.palette_outlined, [
      Skill(
        'Figma',
        FontAwesomeIcons.figma.data,
        'Turning designs into pixel-accurate screens.',
      ),
      Skill(
        'Responsive UI',
        Icons.devices_rounded,
        'Layouts that adapt to every screen size.',
      ),
      Skill(
        'Custom Widgets',
        Icons.widgets_outlined,
        'Reusable, composable UI components.',
      ),
      Skill(
        'Flutter Animations',
        Icons.animation_rounded,
        'Motion that guides and delights users.',
      ),
    ]),
    SkillCategory('Tools', Icons.build_outlined, [
      Skill(
        'Git',
        FontAwesomeIcons.gitAlt.data,
        'Version control and branching workflows.',
      ),
      Skill(
        'GitHub',
        FontAwesomeIcons.github.data,
        'Code hosting and collaboration.',
      ),
      Skill(
        'Android Studio',
        FontAwesomeIcons.android.data,
        'Android builds, profiling and debugging.',
      ),
      Skill(
        'VS Code',
        Icons.terminal_rounded,
        'Day-to-day Flutter development.',
      ),
      Skill(
        'Xcode',
        FontAwesomeIcons.apple.data,
        'iOS builds, signing and debugging.',
      ),
      Skill('Postman', Icons.send_rounded, 'Exploring and testing APIs.'),
    ]),
    SkillCategory('Deployment', Icons.rocket_launch_outlined, [
      Skill(
        'Google Play Console',
        FontAwesomeIcons.googlePlay.data,
        'Releases, app transfers and account migrations.',
      ),
      Skill(
        'App Store Connect',
        FontAwesomeIcons.appStoreIos.data,
        'iOS builds and App Store releases.',
      ),
    ]),
  ];
}
