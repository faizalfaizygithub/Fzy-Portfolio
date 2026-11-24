/// Page sections in scroll order. Items with [inNav] appear in navigation.
enum AppSection {
  home('Home', inNav: true),
  about('About', inNav: true),
  skills('Skills', inNav: true),
  experience('Experience', inNav: true),
  projects('Projects', inNav: true),
  expertise('Expertise'),
  education('Education'),
  contact('Contact', inNav: true);

  const AppSection(this.label, {this.inNav = false});

  final String label;
  final bool inNav;

  static List<AppSection> get navItems =>
      values.where((s) => s.inNav).toList(growable: false);
}
