import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_info.dart';
import '../../../../../core/constants/app_sections.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/utils/link_launcher.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/social_links.dart';
import '../../../../../shared/animations/staggered_words.dart';
import '../../providers/navigation_provider.dart';
import 'code_snippet_card.dart';
import 'hero_background.dart';
import 'tech_orbit.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  /// One-shot entrance timeline for all hero content.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  /// Shared infinite loop for orbit, floating, gradient drift and particles.
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: AppDurations.ambientLoop * 2,
  );

  bool _reduceMotion = false;
  bool _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = context.reduceMotion;
    if (_reduceMotion) {
      _intro.value = 1;
      _ambient.stop();
    } else {
      if (_intro.isDismissed) _intro.forward();
      _syncAmbient();
    }
  }

  /// Run the ambient loop only while the hero is on screen.
  void _syncAmbient() {
    final shouldRun = _visible && !_reduceMotion;
    if (shouldRun && !_ambient.isAnimating) {
      _ambient.repeat();
    } else if (!shouldRun && _ambient.isAnimating) {
      _ambient.stop();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  /// `drive` + CurveTween only attaches to the controller while something
  /// listens, so these never leak listeners.
  Animation<double> _interval(double begin, double end) => _intro.drive(
        CurveTween(curve: Interval(begin, end, curve: AppCurves.emphasized)),
      );

  late final _labelAnim = _interval(0.0, 0.3);
  late final _headingAnim = _interval(0.05, 0.6);
  late final _bodyAnim = _interval(0.35, 0.65);
  late final _chipsAnim = _interval(0.45, 0.75);
  late final _buttonsAnim = _interval(0.55, 0.85);
  late final _socialsAnim = _interval(0.65, 0.95);
  late final _visualAnim = _interval(0.15, 0.7);
  late final _scrollHintAnim = _interval(0.8, 1);
  late final _typingAnim =
      _intro.drive(CurveTween(curve: const Interval(0.35, 1)));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final desktop = context.isDesktop;
    final minHeight = math.max(size.height, desktop ? 720.0 : 0.0);

    final content = _HeroContent(
      label: _labelAnim,
      heading: _headingAnim,
      body: _bodyAnim,
      chips: _chipsAnim,
      buttons: _buttonsAnim,
      socials: _socialsAnim,
    );

    final visual = _HeroVisual(
      ambient: _ambient,
      reveal: _visualAnim,
      typing: _typingAnim,
      size: context.responsive<double>(mobile: math.min(size.width - 40, 360), tablet: 440, desktop: 520),
      showCode: !context.isMobile,
    );

    return VisibilityDetector(
      key: const Key('hero-visibility'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        _visible = info.visibleFraction > 0;
        _syncAmbient();
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Stack(
          // Passes the min height through so the content can center itself.
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(child: HeroBackground(ambient: _ambient)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.horizontalPadding,
                AppSizes.navHeight + context.responsive<double>(mobile: 32, desktop: 48),
                context.horizontalPadding,
                context.responsive<double>(mobile: 48, desktop: 96),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
                  child: desktop
                      ? Row(
                          children: [
                            Expanded(flex: 11, child: content),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(flex: 9, child: Center(child: visual)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            content,
                            const SizedBox(height: AppSpacing.xxl),
                            Center(child: visual),
                          ],
                        ),
                ),
              ),
            ),
            if (desktop)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.xl,
                child: FadeTransition(
                  opacity: _scrollHintAnim,
                  child: Center(child: _ScrollIndicator(ambient: _ambient)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.animation, required this.child, this.dy = 0.3});

  final Animation<double> animation;
  final Widget child;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: Offset(0, dy), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.label,
    required this.heading,
    required this.body,
    required this.chips,
    required this.buttons,
    required this.socials,
  });

  final Animation<double> label;
  final Animation<double> heading;
  final Animation<double> body;
  final Animation<double> chips;
  final Animation<double> buttons;
  final Animation<double> socials;

  static const _specializations = [
    (Icons.flutter_dash_rounded, 'Flutter & Dart'),
    (Icons.cloud_sync_rounded, 'Firebase & Backend Integration'),
    (Icons.videocam_rounded, 'Real-Time Communication'),
    (Icons.layers_rounded, 'Clean Architecture'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final nav = context.read<NavigationProvider>();
    final headingStyle = context.responsive(
      mobile: theme.displaySmall!.copyWith(fontSize: 40),
      tablet: theme.displayMedium,
      desktop: theme.displayLarge!.copyWith(
        fontSize: context.screenWidth < 1280 ? 62 : 72,
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FadeSlide(animation: label, child: const _AvailabilityBadge()),
        const SizedBox(height: AppSpacing.lg),
        StaggeredWords(
          text: 'Building Beautiful Digital Experiences with Flutter.',
          highlight: const {'Beautiful', 'Flutter.'},
          animation: heading,
          style: headingStyle,
        ),
        const SizedBox(height: AppSpacing.lg),
        _FadeSlide(
          animation: body,
          dy: 0.15,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: "I'm "),
                  TextSpan(
                    text: AppInfo.shortName,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(
                    text: ', a Flutter Developer passionate about creating scalable, high-performance, '
                        'and beautifully designed mobile applications.',
                  ),
                ],
              ),
              style: theme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FadeSlide(
          animation: chips,
          dy: 0.4,
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final (icon, text) in _specializations) _SpecChip(icon: icon, label: text),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _FadeSlide(
          animation: buttons,
          dy: 0.6,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: 'Explore My Work',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => nav.scrollTo(AppSection.projects),
              ),
              const AppButton(
                label: 'Download Resume',
                icon: Icons.download_rounded,
                variant: AppButtonVariant.outline,
                onPressed: LinkLauncher.downloadResume,
              ),
              AppButton(
                label: 'Contact Me',
                variant: AppButtonVariant.ghost,
                icon: Icons.north_east_rounded,
                onPressed: () => nav.scrollTo(AppSection.contact),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _FadeSlide(
          animation: socials,
          dy: 0.6,
          child: Row(
            children: [
              const SocialLinks(size: 42),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  '${AppInfo.experience}+ yrs · ${AppInfo.location.split(',').first}, India',
                  style: theme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.button,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PulseDot(),
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(
            child: Text(
              'AVAILABLE FOR OPPORTUNITIES',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontSize: 11.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dot with an expanding halo. The halo is an implicit animation restarted
/// from `onEnd`, so no AnimationController is needed.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const dot = DecoratedBox(
      decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
      child: SizedBox.square(dimension: 8),
    );
    if (context.reduceMotion) return dot;

    return SizedBox.square(
      dimension: 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(_expanded),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1600),
            onEnd: () {
              if (mounted) setState(() => _expanded = !_expanded);
            },
            builder: (context, t, _) => Transform.scale(
              scale: 1 + t * 1.6,
              child: Opacity(
                opacity: (1 - t) * 0.6,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: SizedBox.square(dimension: 8),
                ),
              ),
            ),
          ),
          dot,
        ],
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.7),
        borderRadius: AppRadius.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.highlight),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.85),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({
    required this.ambient,
    required this.reveal,
    required this.typing,
    required this.size,
    required this.showCode,
  });

  final Animation<double> ambient;
  final Animation<double> reveal;
  final Animation<double> typing;
  final double size;
  final bool showCode;

  @override
  Widget build(BuildContext context) {
    final orbit = TechOrbit(ambient: ambient, size: size);

    return FadeTransition(
      opacity: reveal,
      child: ScaleTransition(
        scale: Tween(begin: 0.88, end: 1.0).animate(reveal),
        child: SizedBox(
          width: size,
          height: showCode ? size + size * 0.12 : size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(top: 0, left: 0, child: orbit),
              if (showCode)
                Positioned(
                  left: -size * 0.14,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: ambient,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, math.sin(ambient.value * 2 * math.pi * 4) * 8),
                      child: child,
                    ),
                    child: CodeSnippetCard(progress: typing, width: size * 0.66),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollIndicator extends StatelessWidget {
  const _ScrollIndicator({required this.ambient});

  final Animation<double> ambient;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.5), width: 1.5),
          ),
          child: AnimatedBuilder(
            animation: ambient,
            builder: (context, _) {
              // ~1.6s cycle derived from the long ambient loop.
              final cycles = (AppDurations.ambientLoop * 2).inMilliseconds / 1600;
              final t = (ambient.value * cycles) % 1.0;
              return Align(
                alignment: Alignment(0, -0.6 + t * 1.0),
                child: Opacity(
                  opacity: 1 - t,
                  child: Container(
                    width: 4,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.highlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('SCROLL', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
