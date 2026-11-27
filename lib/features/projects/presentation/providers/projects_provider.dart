import '../../domain/project.dart';
import '../../domain/project_repository.dart';

/// Read-only access to projects for the presentation layer.
class ProjectsProvider {
  ProjectsProvider(this._repository) : projects = _repository.getProjects();

  final ProjectRepository _repository;
  final List<Project> projects;

  Project get spotlight =>
      projects.firstWhere((p) => p.isSpotlight, orElse: () => projects.first);

  List<Project> get others =>
      projects.where((p) => p != spotlight).toList(growable: false);

  Project? byId(String id) => _repository.getProjectById(id);

  /// Neighbouring project for "next project" navigation on detail pages.
  Project next(Project current) {
    final i = projects.indexOf(current);
    return projects[(i + 1) % projects.length];
  }
}
