import 'project.dart';

abstract interface class ProjectRepository {
  List<Project> getProjects();
  Project? getProjectById(String id);
}
