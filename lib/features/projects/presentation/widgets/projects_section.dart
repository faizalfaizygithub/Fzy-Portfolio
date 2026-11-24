import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/animations/reveal.dart';
import '../providers/projects_provider.dart';
import 'project_showcase_card.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = context.read<ProjectsProvider>();
    final spotlight = projects.spotlight;
    final others = projects.others;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            index: '04',
            eyebrow: 'Featured work',
            title: 'Projects I\'ve Built',
            subtitle:
                'Healthcare, e-commerce and real-time communication apps I\'ve contributed to — '
                'from discovery flows and checkout to audio/video calling.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          Reveal(
            offset: const Offset(0, 0.06),
            child: ProjectShowcaseCard(project: spotlight),
          ),
          for (var i = 0; i < others.length; i++) ...[
            const SizedBox(height: AppSpacing.xl),
            Reveal(
              offset: const Offset(0, 0.08),
              child: ProjectShowcaseCard(
                project: others[i],
                reversed: i.isEven,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
