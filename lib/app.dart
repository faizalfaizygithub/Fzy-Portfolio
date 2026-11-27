import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_info.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/contact/data/web3forms_contact_repository.dart';
import 'features/contact/domain/contact_message.dart';
import 'features/contact/presentation/providers/contact_provider.dart';
import 'features/projects/data/local_project_repository.dart';
import 'features/projects/presentation/providers/projects_provider.dart';

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key, this.contactRepository});

  /// Override for tests; defaults to Web3Forms.
  final ContactRepository? contactRepository;

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  late final GoRouter _router = createRouter();
  late final ThemeData _theme = AppTheme.dark();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => ProjectsProvider(const LocalProjectRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ContactProvider(
            widget.contactRepository ?? Web3FormsContactRepository(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: '${AppInfo.name} | ${AppInfo.role} Portfolio',
        debugShowCheckedModeBanner: false,
        theme: _theme,
        darkTheme: _theme,
        themeMode: ThemeMode.dark,
        routerConfig: _router,
      ),
    );
  }
}
