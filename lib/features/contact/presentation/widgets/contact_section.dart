import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../core/widgets/ambient_glow.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../../../../core/widgets/section_container.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/reveal.dart';
import 'contact_form.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final wide = context.isDesktop;
    final titleStyle = context.responsive(
      mobile: theme.headlineMedium!.copyWith(fontSize: 36, height: 1.1),
      tablet: theme.displaySmall,
      desktop: theme.displayMedium,
    );

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(child: Text('// 07 — CONTACT', style: theme.labelSmall)),
        const SizedBox(height: AppSpacing.md),
        Reveal(
          delay: AppDurations.stagger,
          child: Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Let\'s Build Something '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GradientText('Great', style: titleStyle),
                  ),
                  const TextSpan(text: ' Together.'),
                ],
              ),
              style: titleStyle,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Reveal(
          delay: AppDurations.stagger * 2,
          child: Text(
            'Have an exciting project, freelance opportunity, or job opportunity? Feel free to reach out. '
            'I\'d love to connect and discuss how I can contribute.',
            style: theme.bodyLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final (i, info) in _infos.indexed)
          Reveal.staggered(
            index: i,
            base: AppDurations.stagger * 3,
            offset: const Offset(-0.05, 0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ContactInfoTile(info: info),
            ),
          ),
      ],
    );

    final form = Reveal(
      delay: AppDurations.stagger * 2,
      offset: const Offset(0, 0.06),
      child: Container(
        padding: EdgeInsets.all(context.responsive<double>(mobile: AppSpacing.lg, desktop: AppSpacing.xl + 8)),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 60, offset: const Offset(0, 30)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send a message', style: theme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text('I usually reply by email.', style: theme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            const ContactForm(),
          ],
        ),
      ),
    );

    return SectionContainer(
      background: Align(
        alignment: const Alignment(0.8, 0.2),
        child: AmbientGlow(color: AppColors.primary, size: wide ? 800 : 480, opacity: 0.2),
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: intro),
                const SizedBox(width: AppSpacing.xxxl),
                Expanded(flex: 6, child: form),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [intro, const SizedBox(height: AppSpacing.xl), form],
            ),
    );
  }

  static final _infos = <_Info>[
    _Info(Icons.alternate_email_rounded, 'Email', AppInfo.email, LinkLauncher.email),
    _Info(Icons.phone_rounded, 'Phone', AppInfo.phone, LinkLauncher.phone),
    _Info(FontAwesomeIcons.linkedinIn.data, 'LinkedIn', AppInfo.linkedInLabel, LinkLauncher.linkedIn),
    const _Info(Icons.location_on_outlined, 'Location', AppInfo.location, null),
  ];
}

class _Info {
  const _Info(this.icon, this.label, this.value, this.onTap);
  final IconData icon;
  final String label;
  final String value;
  final Future<bool> Function()? onTap;
}

class _ContactInfoTile extends StatelessWidget {
  const _ContactInfoTile({required this.info});

  final _Info info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final interactive = info.onTap != null;
    return HoverBuilder(
      onTap: interactive ? () => info.onTap!() : null,
      semanticLabel: '${info.label}: ${info.value}',
      builder: (context, hovered) => AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: hovered ? AppColors.card : AppColors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: hovered ? AppColors.primary.withValues(alpha: 0.6) : AppColors.border),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppDurations.fast,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: hovered ? AppColors.brandGradient : null,
                color: hovered ? null : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(info.icon, size: 18, color: hovered ? AppColors.textPrimary : AppColors.highlight),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.label.toUpperCase(), style: theme.labelSmall?.copyWith(fontSize: 10.5, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    info.value,
                    style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (interactive)
              AnimatedSlide(
                duration: AppDurations.fast,
                offset: hovered ? const Offset(0.2, -0.2) : Offset.zero,
                child: Icon(Icons.north_east_rounded, size: 16, color: hovered ? AppColors.highlight : AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}
