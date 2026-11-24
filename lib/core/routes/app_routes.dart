import '../constants/app_sections.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const projectPattern = '/projects/:id';

  static String project(String id) => '/projects/$id';

  /// Home URL that scrolls to [section] after loading, e.g. `/?section=contact`.
  static String homeSection(AppSection section) =>
      Uri(path: home, queryParameters: {'section': section.name}).toString();
}
