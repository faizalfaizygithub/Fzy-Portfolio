import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_sections.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../shared/widgets/back_to_top_button.dart';
import '../../../../shared/widgets/custom_cursor.dart';
import '../../../../shared/widgets/preloader.dart';
import '../../../../shared/widgets/scroll_progress_bar.dart';
import '../../../about/presentation/widgets/about_section.dart';
import '../../../contact/presentation/widgets/contact_section.dart';
import '../../../education/presentation/widgets/education_section.dart';
import '../../../experience/presentation/widgets/experience_section.dart';
import '../../../expertise/presentation/widgets/expertise_section.dart';
import '../../../footer/presentation/widgets/footer_section.dart';
import '../../../process/presentation/widgets/process_section.dart';
import '../../../projects/presentation/widgets/projects_section.dart';
import '../../../skills/presentation/widgets/skills_section.dart';
import '../../../skills/presentation/widgets/tech_marquee.dart';
import '../providers/intro_controller.dart';
import '../providers/navigation_provider.dart';
import '../widgets/hero/hero_section.dart';
import '../widgets/nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialSection});

  /// Section to scroll to after loading (from `/?section=...`).
  final AppSection? initialSection;

  /// The preloader plays once per app session, not on every return home.
  static bool _introPlayed = false;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nav = NavigationProvider();
  late final _intro = IntroController(
    done:
        HomeScreen._introPlayed ||
        (widget.initialSection != null &&
            widget.initialSection != AppSection.home),
  );
  late bool _showPreloader = !_intro.done;

  @override
  void initState() {
    super.initState();
    _scrollToInitial(widget.initialSection);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion && _showPreloader) {
      _showPreloader = false;
      _intro.finish();
    }
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
    _intro.dispose();
    super.dispose();
  }

  Widget _section(AppSection section, Widget child) =>
      KeyedSubtree(key: _nav.keyFor(section), child: child);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _nav),
        ChangeNotifierProvider.value(value: _intro),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomCursorOverlay(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _nav.scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _section(AppSection.home, const HeroSection()),
                    const TechMarquee(),
                    _section(AppSection.about, const AboutSection()),
                    _section(AppSection.experience, const ExperienceSection()),
                    _section(AppSection.projects, const ProjectsSection()),
                    _section(AppSection.process, const ProcessSection()),
                    _section(AppSection.expertise, const ExpertiseSection()),
                    _section(AppSection.skills, const SkillsSection()),
                    _section(AppSection.education, const EducationSection()),
                    _section(AppSection.contact, const ContactSection()),
                    FooterSection(onNavigate: _nav.scrollTo),
                  ],
                ),
              ),
              if (!context.isDesktop)
                const Positioned.fill(child: MenuOverlay()),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(bottom: false, child: NavBar()),
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
                  selector: (_, n) => n.showBackToTop && !n.menuOpen,
                  builder: (context, visible, _) => BackToTopButton(
                    visible: visible,
                    onTap: _nav.scrollToTop,
                  ),
                ),
              ),
              if (_showPreloader)
                Positioned.fill(
                  child: Preloader(
                    onReveal: () {
                      HomeScreen._introPlayed = true;
                      _intro.finish();
                    },
                    onFinished: () {
                      if (mounted) setState(() => _showPreloader = false);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
