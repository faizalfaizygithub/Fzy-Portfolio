import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_sections.dart';

/// Owns the page scroll position and which section is active.
///
/// Listeners are notified only when [activeSection], [isScrolled] or
/// [showBackToTop] change, so scrolling doesn't rebuild the page.
/// Widgets that need every pixel (the progress bar) listen to
/// [scrollController] directly.
class NavigationProvider extends ChangeNotifier {
  NavigationProvider() {
    scrollController.addListener(_onScroll);
  }

  final scrollController = ScrollController();
  final Map<AppSection, GlobalKey> _keys = {
    for (final s in AppSection.values) s: GlobalKey(debugLabel: s.name),
  };

  AppSection _activeSection = AppSection.home;
  bool _isScrolled = false;
  bool _showBackToTop = false;

  /// Section the user picked; keeps it highlighted during the animated scroll
  /// instead of flickering through the sections in between.
  AppSection? _pendingTarget;

  AppSection get activeSection => _activeSection;
  bool get isScrolled => _isScrolled;
  bool get showBackToTop => _showBackToTop;

  GlobalKey keyFor(AppSection section) => _keys[section]!;

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final offset = scrollController.offset;
    var changed = false;

    final scrolled = offset > 24;
    if (scrolled != _isScrolled) {
      _isScrolled = scrolled;
      changed = true;
    }

    final viewport = scrollController.position.viewportDimension;
    final backToTop = offset > viewport * 0.8;
    if (backToTop != _showBackToTop) {
      _showBackToTop = backToTop;
      changed = true;
    }

    if (_pendingTarget == null) {
      final active = _computeActiveSection(viewport);
      if (active != null && active != _activeSection) {
        _activeSection = active;
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  /// The active section is the last one whose top has passed 35% of the
  /// viewport height. Nav-only sections map non-nav ones to the previous
  /// nav item (e.g. Expertise → Projects, Education → Projects).
  AppSection? _computeActiveSection(double viewport) {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 4) {
      return AppSection.contact;
    }

    AppSection? current;
    for (final section in AppSection.values) {
      final box =
          _keys[section]!.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top <= viewport * 0.35) current = section;
    }
    if (current == null) return null;
    return _navSectionFor(current);
  }

  AppSection _navSectionFor(AppSection section) {
    if (section.inNav) return section;
    final nav = AppSection.values
        .take(section.index)
        .lastWhere((s) => s.inNav, orElse: () => AppSection.home);
    return nav;
  }

  Future<void> scrollTo(AppSection section, {bool animate = true}) async {
    final context = _keys[section]!.currentContext;
    if (context == null) return;

    _pendingTarget = section;
    if (_activeSection != section) {
      _activeSection = section;
      notifyListeners();
    }

    try {
      await Scrollable.ensureVisible(
        context,
        duration: animate ? AppDurations.scrollTo : Duration.zero,
        curve: AppCurves.scroll,
      );
    } finally {
      _pendingTarget = null;
    }
  }

  Future<void> scrollToTop() => scrollTo(AppSection.home);

  @override
  void dispose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}
