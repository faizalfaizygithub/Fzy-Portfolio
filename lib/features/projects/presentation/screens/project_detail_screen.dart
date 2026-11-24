import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/app_sections.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/ambient_glow.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/glow_card.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../../footer/presentation/widgets/footer_section.dart';
import '../../domain/project.dart';
import '../providers/projects_provider.dart';
import '../widgets/open_project.dart';
import '../widgets/project_gallery.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.homeSection(AppSection.projects));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectsProvider>();
    final project = provider.byId(projectId);

    if (project == null) return _NotFound(onBack: () => _back(context));

    return Title(
      title: '${project.name} | ${AppInfo.name}',
      color: AppColors.primary,
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(project: project),
                  _Gallery(project: project),
                  _Details(project: project),
                  _NextProject(project: provider.next(project)),
                  FooterSection(
                    onNavigate: (section) =>
                        context.go(AppRoutes.homeSection(section)),
                  ),
                ],
              ),
            ),
            _TopBar(onBack: () => _back(context)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.navHeight,
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, AppColors.background.withValues(alpha: 0)],
        ),
      ),
      child: Row(
        children: [
          HoverBuilder(
            onTap: onBack,
            semanticLabel: 'Back to all projects',
            builder: (context, hovered) => AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: hovered ? AppColors.card : AppColors.card.withValues(alpha: 0.6),
                borderRadius: AppRadius.button,
                border: Border.all(
                  color: hovered ? AppColors.highlight : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSlide(
                    duration: AppDurations.fast,
                    offset: hovered ? const Offset(-0.25, 0) : Offset.zero,
                    child: const Icon(Icons.arrow_back_rounded, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('All projects', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
          const Spacer(),
          BrandLogo(
            onTap: () => context.go(AppRoutes.home),
            showTag: !context.isMobile,
            size: context.isMobile ? 36 : 40,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return SectionContainer(
      verticalPadding: 0,
      background: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -200,
            right: -150,
            child: AmbientGlow(color: project.accent, size: 700, opacity: 0.22),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: AppSizes.navHeight + context.responsive<double>(mobile: 32, desktop: 72),
          bottom: AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Reveal(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('// ${project.number}',
                      style: theme.labelSmall?.copyWith(color: project.accent)),
                  TagChip(project.category, accent: project.accent),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              delay: AppDurations.stagger,
              child: GradientText(
                project.name,
                gradient: LinearGradient(
                  colors: [AppColors.textPrimary, project.accent, AppColors.highlight],
                ),
                style: context.responsive(
                  mobile: theme.displaySmall,
                  desktop: theme.displayLarge?.copyWith(fontSize: 96),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              delay: AppDurations.stagger * 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(project.overview, style: theme.bodyLarge),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              delay: AppDurations.stagger * 3,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [for (final t in project.technologies) TagChip(t)],
              ),
            ),
            if (project.hasWebsite) ...[
              const SizedBox(height: AppSpacing.xl),
              Reveal(
                delay: AppDurations.stagger * 4,
                child: AppButton(
                  label: 'Visit website',
                  icon: Icons.north_east_rounded,
                  onPressed: () => LinkLauncher.open(project.websiteUrl!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      padding: EdgeInsets.symmetric(
        vertical: context.responsive<double>(mobile: AppSpacing.xl, desktop: AppSpacing.xxxl),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        gradient: RadialGradient(
          radius: 1.1,
          colors: [project.accent.withValues(alpha: 0.12), AppColors.backgroundAlt],
        ),
      ),
      child: Column(
        children: [
          Text('PROJECT GALLERY', style: theme.labelSmall),
          const SizedBox(height: AppSpacing.xl),
          ProjectGallery(project: project),
          if (!project.hasScreenshots) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Illustrative interface previews. Real app screenshots will be added here.',
                textAlign: TextAlign.center,
                style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final contributions = _Panel(
      title: 'My contributions',
      accent: project.accent,
      child: Column(
        children: [
          for (var i = 0; i < project.contributions.length; i++)
            Reveal.staggered(
              index: i,
              offset: const Offset(0.04, 0),
              child: _ContributionRow(
                text: project.contributions[i],
                accent: project.accent,
              ),
            ),
        ],
      ),
    );

    final features = _Panel(
      title: 'Key features',
      accent: project.accent,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (var i = 0; i < project.keyFeatures.length; i++)
            Reveal.staggered(
              index: i,
              scaleFrom: 0.92,
              child: _FeatureTile(
                text: project.keyFeatures[i],
                accent: project.accent,
              ),
            ),
        ],
      ),
    );

    final overview = _Panel(
      title: 'Overview',
      accent: project.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Fact(label: 'Project', value: project.name),
          _Fact(label: 'Category', value: project.category),
          _Fact(label: 'Role', value: AppInfo.role),
          _Fact(label: 'Stack', value: project.technologies.join(' · ')),
        ],
      ),
    );

    return SectionContainer(
      verticalPadding: context.responsive<double>(mobile: AppSpacing.xxl, desktop: AppSpacing.xxxl + 16),
      child: context.isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: contributions),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Reveal(child: overview),
                      const SizedBox(height: AppSpacing.lg),
                      features,
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                contributions,
                const SizedBox(height: AppSpacing.lg),
                features,
                const SizedBox(height: AppSpacing.lg),
                Reveal(child: overview),
              ],
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.accent, required this.child});

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsive<double>(mobile: AppSpacing.lg, desktop: AppSpacing.xl)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 18, color: accent),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Semantics(
                  header: true,
                  child: Text(title, style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _ContributionRow extends StatelessWidget {
  const _ContributionRow({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hovered) => AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: hovered ? accent.withValues(alpha: 0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_rounded, size: 20, color: accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 16, color: accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: theme.labelSmall?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NextProject extends StatelessWidget {
  const _NextProject({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return SectionContainer(
      verticalPadding: AppSpacing.lg,
      child: Reveal(
        child: GlowCard(
          accent: project.accent,
          radius: AppRadius.xl,
          padding: EdgeInsets.all(
            context.responsive<double>(mobile: AppSpacing.lg, desktop: AppSpacing.xxl),
          ),
          semanticLabel: 'Next project: ${project.name}',
          onTap: () => openProject(context, project, replace: true),
          builder: (context, hovered, _) => Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NEXT PROJECT', style: theme.labelSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      project.name,
                      style: context.responsive(
                        mobile: theme.headlineMedium,
                        desktop: theme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(project.category, style: theme.bodyMedium),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: AppDurations.medium,
                curve: AppCurves.smooth,
                width: 64,
                height: 64,
                transform: Matrix4.translationValues(hovered ? 6 : 0, 0, 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hovered ? project.accent : AppColors.backgroundAlt,
                  border: Border.all(color: hovered ? project.accent : AppColors.border),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: hovered ? AppColors.background : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('404', style: theme.labelSmall),
              const SizedBox(height: AppSpacing.md),
              Text('Project not found', style: theme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Back to projects', icon: Icons.arrow_back_rounded, onPressed: onBack),
            ],
          ),
        ),
      ),
    );
  }
}
