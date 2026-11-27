import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/app_sections.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/roll_text.dart';
import '../../../../shared/animations/scroll_select.dart';

/// Footer: brand line, sitemap / social / contact columns and a giant
/// wordmark whose letters rise as you reach the bottom of the page.
class FooterSection extends StatelessWidget {
  const FooterSection({super.key, required this.onNavigate});

  final void Function(AppSection section) onNavigate;

  @override
  Widget build(BuildContext context) {
    final g = gutter(context);
    final wide = !context.isMobile;
    final theme = Theme.of(context).textTheme;

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppInfo.role}, ${AppInfo.location.split(',').first}, Kerala.',
          style: AppTypography.heading(
            TextStyle(
              fontSize: fluid(context, 22, 30),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.6,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Open to remote & full-time roles.',
          style: AppTypography.heading(
            TextStyle(
              fontSize: fluid(context, 22, 30),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.6,
              height: 1.2,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );

    final columns = Wrap(
      spacing: fluid(context, 48, 96),
      runSpacing: 36,
      children: [
        _FooterColumn(
          title: 'Sitemap',
          links: [
            for (final s in AppSection.navItems) (s.label, () => onNavigate(s)),
          ],
        ),
        _FooterColumn(
          title: 'Social',
          links: [
            ('LinkedIn', LinkLauncher.linkedIn),
            if (AppInfo.hasGitHub) ('GitHub', LinkLauncher.gitHub),
            ('Resume', LinkLauncher.downloadResume),
          ],
        ),
        _FooterColumn(
          title: 'Contact',
          links: [
            (AppInfo.email, LinkLauncher.email),
            (AppInfo.phone, LinkLauncher.phone),
          ],
        ),
      ],
    );

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(g, fluid(context, 64, 112), g, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: wide && context.isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: brand),
                          const SizedBox(width: 48),
                          columns,
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [brand, const SizedBox(height: 48), columns],
                      ),
              ),
            ),
          ),
          SizedBox(height: fluid(context, 56, 96)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: g),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '© ${AppInfo.copyrightYear} ${AppInfo.name}. All Rights Reserved.',
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (wide)
                  Text(
                    'DESIGNED & BUILT WITH FLUTTER',
                    style: AppTypography.eyebrow(
                      color: AppColors.textMuted,
                      size: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Wordmark(),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});

  final String title;
  final List<(String, VoidCallback)> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.eyebrow(color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        for (final (label, onTap) in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HoverBuilder(
              onTap: onTap,
              semanticLabel: label,
              builder: (context, h) => RollText(
                label,
                active: h,
                style: AppTypography.label(
                  const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final letters = AppInfo.firstName.toUpperCase().split('');
    final style = AppTypography.wordmark(
      const TextStyle(
        fontSize: 300,
        height: 1.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -6,
        color: AppColors.raised,
      ),
    );
    final motion = !context.reduceMotion;

    return ExcludeSemantics(
      child: ScrollSelect<double>(
        initial: motion ? 0 : 1,
        select: (m) => motion ? quantize(m.range(1.0, 1.0), 200) : 1,
        builder: (context, p, _) => ClipRect(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < letters.length; i++)
                    _WordmarkLetter(
                      letter: letters[i],
                      style: style,
                      // Stagger: each letter starts slightly later.
                      t: ((p * 1.6) - i * 0.1).clamp(0.0, 1.0),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordmarkLetter extends StatelessWidget {
  const _WordmarkLetter({
    required this.letter,
    required this.style,
    required this.t,
  });

  final String letter;
  final TextStyle style;
  final double t;

  @override
  Widget build(BuildContext context) {
    final eased = AppCurves.power4Out.transform(t);
    return HoverBuilder(
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: AppCurves.spring,
        offset: Offset(0, hovered ? -0.06 : 0),
        child: FractionalTranslation(
          translation: Offset(0, 0.55 * (1 - eased)),
          child: AnimatedDefaultTextStyle(
            duration: AppDurations.medium,
            style: style.copyWith(
              color: hovered ? AppColors.textPrimary : AppColors.raised,
            ),
            child: Text(letter),
          ),
        ),
      ),
    );
  }
}
