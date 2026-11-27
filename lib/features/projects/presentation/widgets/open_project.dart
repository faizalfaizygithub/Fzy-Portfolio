import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../domain/project.dart';

/// Opens a project's detail page. [replace] swaps the current detail page
/// instead of pushing a new one (used by "Next project").
void openProject(
  BuildContext context,
  Project project, {
  bool replace = false,
}) {
  final route = AppRoutes.project(project.id);
  if (replace) {
    context.pushReplacement(route);
  } else {
    context.push(route);
  }
}
