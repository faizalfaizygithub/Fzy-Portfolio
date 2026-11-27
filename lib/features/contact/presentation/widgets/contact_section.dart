import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/line_reveal.dart';
import '../../../../shared/animations/magnetic.dart';
import '../../../../shared/animations/reveal.dart';
import 'contact_form.dart';

/// Closing call to action: a large spotlight panel with a huge headline,
/// direct contact links and the message form.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = context.isDesktop;
    final pad = fluid(context, 24, 64);

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Contact', index: '08'),
        const SizedBox(height: AppSpacing.lg),
        LineReveal(
          lines: const ["Let's build", 'something real.'],
          lineColors: const [null, AppColors.textSecondary],
          style: AppTypography.display(fluid(context, 44, 96)),
        ),
        const SizedBox(height: AppSpacing.xl),
        Reveal(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              'Have an app idea, a Figma file waiting to come alive, or a role '
              'on your team? Send a message — I read every one.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Reveal(
          delay: AppDurations.stagger,
          child: Magnetic(
            strength: 0.15,
            child: _BigLink(label: AppInfo.email, onTap: LinkLauncher.email),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Reveal(
          delay: AppDurations.stagger * 2,
          child: Wrap(
            spacing: 24,
            runSpacing: 10,
            children: [
              _SmallLink('Phone · ${AppInfo.phone}', LinkLauncher.phone),
              _SmallLink('LinkedIn', LinkLauncher.linkedIn),
              if (AppInfo.hasGitHub) _SmallLink('GitHub', LinkLauncher.gitHub),
              _SmallLink('Resume', LinkLauncher.downloadResume),
            ],
          ),
        ),
      ],
    );

    final form = Reveal(
      offset: const Offset(0, 0.06),
      child: Container(
        padding: EdgeInsets.all(fluid(context, 20, 32)),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: const ContactForm(),
      ),
    );

    return Section(
      top: 0,
      maxWidth: 1400,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.panelGlow,
          borderRadius: BorderRadius.circular(fluid(context, 32, 48)),
          border: Border.all(color: AppColors.border),
        ),
        padding: EdgeInsets.all(pad),
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: intro),
                  SizedBox(width: fluid(context, 32, 72)),
                  Expanded(flex: 5, child: form),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  intro,
                  const SizedBox(height: AppSpacing.xxl),
                  form,
                ],
              ),
      ),
    );
  }
}

/// Email link with an underline that sweeps across on hover.
class _BigLink extends StatelessWidget {
  const _BigLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: 'Email $label',
      builder: (context, hovered) => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.heading(
                      TextStyle(
                        fontSize: fluid(context, 19, 32),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  duration: AppDurations.medium,
                  curve: AppCurves.spring,
                  turns: hovered ? 0.125 : 0,
                  child: const Icon(
                    Icons.north_east_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              children: [
                Container(height: 1.5, color: AppColors.borderStrong),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 600),
                  curve: AppCurves.inOut,
                  widthFactor: hovered ? 1 : 0,
                  child: Container(height: 1.5, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallLink extends StatelessWidget {
  const _SmallLink(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, h) => Text(
        label,
        style: AppTypography.label(
          TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: h ? AppColors.textPrimary : AppColors.textSecondary,
            decoration: h ? TextDecoration.underline : null,
            decorationColor: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
