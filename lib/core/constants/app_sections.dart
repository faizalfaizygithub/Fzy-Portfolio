/// Page sections in scroll order. Items with [inNav] appear in navigation.
enum AppSection {
  home('Home', inNav: true),
  about('About', inNav: true),
  experience('Experience'),
  projects('Work', inNav: true),
  process('Process', inNav: true),
  expertise('Capabilities'),
  skills('Stack', inNav: true),
  education('Education'),
  contact('Contact', inNav: true);

  const AppSection(this.label, {this.inNav = false});

  final String label;
  final bool inNav;

  static List<AppSection> get navItems =>
      values.where((s) => s.inNav).toList(growable: false);
}
