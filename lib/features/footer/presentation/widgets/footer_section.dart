import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/app_sections.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../core/widgets/social_links.dart';
import '../../../../shared/animations/hover_builder.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key, required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final wide = context.isDesktop;

    final brand = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        GradientText(
          AppInfo.name.toUpperCase(),
          style: theme.headlineSmall?.copyWith(letterSpacing: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${AppInfo.role} | Building Digital Experiences.',
          style: theme.bodyMedium,
          textAlign: wide ? TextAlign.start : TextAlign.center,
        ),
      ],
    );

    final links = Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        for (final section in AppSection.navItems)
          _FooterLink(label: section.label, onTap: () => onNavigate(section)),
      ],
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.backgroundAlt,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SectionContainer(
        verticalPadding: AppSpacing.xxl,
        child: Column(
          children: [
            if (wide)
              Row(
                children: [
                  Expanded(child: brand),
                  links,
                  const SizedBox(width: AppSpacing.xl),
                  const SocialLinks(size: 40),
                ],
              )
            else ...[
              brand,
              const SizedBox(height: AppSpacing.lg),
              links,
              const SizedBox(height: AppSpacing.lg),
              const SocialLinks(size: 40),
            ],
            const SizedBox(height: AppSpacing.xl),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '© ${AppInfo.copyrightYear} ${AppInfo.name}. All Rights Reserved.',
              style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Designed & built with Flutter.',
              style: theme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, hovered) => AnimatedDefaultTextStyle(
        duration: AppDurations.fast,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: hovered ? AppColors.textPrimary : AppColors.textSecondary,
            ),
        child: Text(label),
      ),
    );
  }
}
