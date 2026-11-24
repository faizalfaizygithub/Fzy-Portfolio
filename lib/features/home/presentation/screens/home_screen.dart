import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_sections.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../shared/widgets/back_to_top_button.dart';
import '../../../../shared/widgets/custom_cursor.dart';
import '../../../../shared/widgets/scroll_progress_bar.dart';
import '../../../about/presentation/widgets/about_section.dart';
import '../../../contact/presentation/widgets/contact_section.dart';
import '../../../education/presentation/widgets/education_section.dart';
import '../../../experience/presentation/widgets/experience_section.dart';
import '../../../expertise/presentation/widgets/expertise_section.dart';
import '../../../footer/presentation/widgets/footer_section.dart';
import '../../../projects/presentation/widgets/projects_section.dart';
import '../../../skills/presentation/widgets/skills_section.dart';
import '../providers/navigation_provider.dart';
import '../widgets/hero/hero_section.dart';
import '../widgets/nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialSection});

  /// Section to scroll to after loading (from `/?section=...`).
  final AppSection? initialSection;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nav = NavigationProvider();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scrollToInitial(widget.initialSection);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSection != oldWidget.initialSection) {
      _scrollToInitial(widget.initialSection);
    }
  }

  void _scrollToInitial(AppSection? section) {
    if (section == null || section == AppSection.home) return;
    // Wait for layout (and lazy fonts) before jumping.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(AppDurations.medium);
      if (!mounted) return;
      await _nav.scrollTo(section);
      // Web fonts may finish loading after the first jump and reflow the
      // page; settle on the section again once layout is stable.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) await _nav.scrollTo(section);
    });
  }

  @override
  void dispose() {
    _nav.dispose();
    super.dispose();
  }

  Widget _section(AppSection section, Widget child) =>
      KeyedSubtree(key: _nav.keyFor(section), child: child);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _nav,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: context.isDesktop ? null : const NavDrawer(),
        body: CustomCursorOverlay(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _nav.scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _section(AppSection.home, const HeroSection()),
                    _section(AppSection.about, const AboutSection()),
                    _section(AppSection.skills, const SkillsSection()),
                    _section(AppSection.experience, const ExperienceSection()),
                    _section(AppSection.projects, const ProjectsSection()),
                    _section(AppSection.expertise, const ExpertiseSection()),
                    _section(AppSection.education, const EducationSection()),
                    _section(AppSection.contact, const ContactSection()),
                    FooterSection(onNavigate: _nav.scrollTo),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: NavBar(
                    onOpenMenu: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ScrollProgressBar(controller: _nav.scrollController),
              ),
              Positioned(
                right: context.responsive<double>(mobile: 16, desktop: 32),
                bottom: context.responsive<double>(mobile: 16, desktop: 32),
                child: Selector<NavigationProvider, bool>(
                  selector: (_, n) => n.showBackToTop,
                  builder: (context, visible, _) => BackToTopButton(
                    visible: visible,
                    onTap: _nav.scrollToTop,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
