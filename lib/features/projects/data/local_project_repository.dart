import '../domain/project.dart';
import '../domain/project_repository.dart';
import 'projects_local_data_source.dart';

class LocalProjectRepository implements ProjectRepository {
  const LocalProjectRepository();

  @override
  List<Project> getProjects() => ProjectsLocalDataSource.projects;

  @override
  Project? getProjectById(String id) {
    for (final project in ProjectsLocalDataSource.projects) {
      if (project.id == id) return project;
    }
    return null;
  }
}
