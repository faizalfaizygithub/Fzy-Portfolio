import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/app_sections.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/line_reveal.dart';
import '../../../../shared/animations/reveal.dart';
import '../../../../shared/animations/scroll_select.dart';
import '../../../../shared/animations/scrub_text.dart';
import '../../../../shared/widgets/rotating_badge.dart';
import '../../../home/presentation/providers/navigation_provider.dart';

/// "Behind the code": headline, a manifesto that lights up word by word as
/// you scroll, and a portrait card.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const manifesto =
      "I'm ${AppInfo.shortName}, a Flutter developer from Calicut with "
      '${AppInfo.experience} years of turning Figma files into production apps. '
      'I care about the details people feel but rarely notice — the 60fps '
      'scroll, the instant tap, the checkout that just works.';

  static const body =
      'From healthcare booking to e-commerce and real-time calling, I build '
      'cross-platform apps with clean architecture, careful state management '
      'and motion that has a reason to exist.';

  @override
  Widget build(BuildContext context) {
    final wide = context.isDesktop;
    final headline = LineReveal(
      lines: const ['Turning ideas into', 'apps that feel native.'],
      lineColors: const [null, AppColors.textMuted],
      style: AppTypography.display(fluid(context, 40, 84)),
    );

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScrubText(
          manifesto,
          style: AppTypography.heading(
            TextStyle(
              fontSize: fluid(context, 21, 30),
              height: 1.35,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Reveal(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Reveal(
          delay: AppDurations.stagger,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: 'Get in touch',
                icon: Icons.north_east_rounded,
                onPressed: () => context.read<NavigationProvider>().scrollTo(
                  AppSection.contact,
                ),
              ),
              AppButton(
                label: 'Download CV',
                icon: Icons.south_rounded,
                variant: AppButtonVariant.outline,
                onPressed: LinkLauncher.downloadResume,
              ),
            ],
          ),
        ),
      ],
    );

    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionLabel('Behind the code', index: '01'),
              ),
              if (!context.isMobile)
                Text(
                  AppInfo.location.toUpperCase(),
                  style: AppTypography.eyebrow(color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          headline,
          SizedBox(height: fluid(context, 48, 96)),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 5, child: _PortraitCard()),
                SizedBox(width: fluid(context, 40, 96)),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: copy,
                  ),
                ),
              ],
            )
          else ...[
            copy,
            const SizedBox(height: AppSpacing.xxl),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: const _PortraitCard(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Grayscale portrait that blooms into colour on hover, drifting inside its
/// frame as the page scrolls.
class _PortraitCard extends StatelessWidget {
  const _PortraitCard();

  static const _grayscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final motion = !context.reduceMotion;
    return Reveal(
      scaleFrom: 0.94,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: HoverBuilder(
                cursor: SystemMouseCursors.basic,
                builder: (context, hovered) => ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: ColoredBox(
                    color: AppColors.paper,
                    child: ScrollSelect<double>(
                      initial: 0.5,
                      select: (m) => quantize(m.passThrough, 300),
                      builder: (context, p, child) => Transform.translate(
                        offset: Offset(0, motion ? (p - 0.5) * -60 : 0),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 900),
                          curve: AppCurves.out,
                          scale: hovered ? 1.12 : 1.06,
                          child: child,
                        ),
                      ),
                      child: _ColorBloom(
                        hovered: hovered,
                        grayscale: _grayscale,
                        child: Image.asset(
                          AppInfo.portrait,
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -0.6),
                          semanticLabel: 'Portrait of ${AppInfo.name}',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.82),
                  borderRadius: AppRadius.button,
                ),
                child: Text(
                  '( ${AppInfo.role.toUpperCase()} )',
                  style: AppTypography.eyebrow(
                    color: AppColors.textPrimary,
                    size: 11,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -18,
              top: -18,
              child: RotatingBadge(
                text: ' FLUTTER DEVELOPER • BASED IN KERALA •',
                size: fluid(context, 104, 132),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorBloom extends StatelessWidget {
  const _ColorBloom({
    required this.hovered,
    required this.grayscale,
    required this.child,
  });

  final bool hovered;
  final ColorFilter grayscale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(colorFilter: grayscale, child: child),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 700),
          curve: AppCurves.out,
          opacity: hovered ? 1 : 0,
          child: child,
        ),
      ],
    );
  }
}
