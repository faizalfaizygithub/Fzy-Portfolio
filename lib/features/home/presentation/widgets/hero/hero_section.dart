import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimens.dart';
import '../../../../../core/constants/app_info.dart';
import '../../../../../core/constants/app_sections.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/link_launcher.dart';
import '../../../../../core/widgets/editorial.dart';
import '../../../../../shared/animations/hover_builder.dart';
import '../../../../../shared/animations/scroll_select.dart';
import '../../../../../shared/widgets/blend_mask.dart';
import '../../providers/intro_controller.dart';
import '../../providers/navigation_provider.dart';

/// White, full-height hero: portrait anchored to the bottom, a giant first
/// name that rises letter by letter and inverts over the portrait
/// (difference blend), role and links in the corners.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  /// Pointer position normalised to -1..1, for subtle parallax.
  final _pointer = ValueNotifier<Offset>(Offset.zero);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mobile = !context.isDesktop && size.width < Breakpoints.desktop;
    final height = (size.height).clamp(mobile ? 560.0 : 620.0, 1400.0);
    final play = context.select<IntroController, bool>((c) => c.done);
    final motion = !context.reduceMotion;

    final layout = mobile
        ? _MobileLayout(width: size.width, height: height)
        : _DesktopLayout(width: size.width, height: height);

    return MouseRegion(
      onHover: motion
          ? (e) => _pointer.value = Offset(
              (e.position.dx / size.width) * 2 - 1,
              (e.position.dy / height) * 2 - 1,
            )
          : null,
      onExit: (_) => _pointer.value = Offset.zero,
      child: SizedBox(
        height: height,
        child: ScrollSelect<double>(
          initial: 0,
          // How far the hero has scrolled away (0..1).
          select: (m) => quantize((-m.top / m.height).clamp(0.0, 1.0), 300),
          builder: (context, scrolled, _) => ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.paper),
                // Portrait.
                Positioned(
                  left: layout.portraitRect.left,
                  top: layout.portraitRect.top,
                  width: layout.portraitRect.width,
                  height: layout.portraitRect.height,
                  child: _Portrait(
                    play: play,
                    pointer: _pointer,
                    scrolled: motion ? scrolled : 0,
                  ),
                ),
                // Giant name (difference blend).
                Positioned(
                  left: layout.nameRect.left,
                  top: layout.nameRect.top,
                  width: layout.nameRect.width,
                  child: _HeroName(
                    play: play,
                    pointer: _pointer,
                    scrolled: motion ? scrolled : 0,
                  ),
                ),
                ...layout.corners(context, play),
                // Darken as the hero scrolls away, so the dark page below
                // feels like it rises over it.
                if (motion)
                  IgnorePointer(
                    child: ColoredBox(
                      color: AppColors.background.withValues(
                        alpha: (scrolled * 0.9).clamp(0.0, 0.9),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Positions for the desktop composition.
abstract class _Layout {
  Rect get portraitRect;
  Rect get nameRect;
  List<Widget> corners(BuildContext context, bool play);
}

class _DesktopLayout implements _Layout {
  _DesktopLayout({required this.width, required this.height});

  final double width;
  final double height;

  static const _aspect = 1052 / 1494;

  @override
  Rect get portraitRect {
    final h = (height - 64).clamp(420.0, 1300.0);
    final w = (h * _aspect).clamp(0.0, width * 0.5);
    final realH = w / _aspect;
    return Rect.fromLTWH(width * 0.5 + width * 0.029, height - realH, w, realH);
  }

  @override
  Rect get nameRect => Rect.fromLTWH(
    width * 0.039,
    (height * 0.27).clamp(216.0, 400.0),
    width * 0.8,
    0,
  );

  @override
  List<Widget> corners(BuildContext context, bool play) {
    final g = gutter(context);
    return [
      Positioned(
        left: g,
        bottom: 48,
        child: _Delayed(
          play: play,
          delay: 650,
          child: const BlendMask(
            blendMode: BlendMode.difference,
            child: _HeroLinks(vertical: true),
          ),
        ),
      ),
      Positioned(
        left: g,
        top: 108,
        width: 300,
        child: _Delayed(play: play, delay: 550, child: const _HeroBlurb()),
      ),
      Positioned(
        right: g,
        bottom: 40,
        child: _Delayed(
          play: play,
          delay: 500,
          child: BlendMask(
            blendMode: BlendMode.difference,
            child: _HeroRole(size: fluid(context, 30, 46)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 28,
        child: _Delayed(play: play, delay: 900, child: const _ScrollCue()),
      ),
    ];
  }
}

class _MobileLayout implements _Layout {
  _MobileLayout({required this.width, required this.height});

  final double width;
  final double height;

  static const _aspect = 1052 / 1494;

  @override
  Rect get portraitRect {
    final w = (width * 1.08).clamp(0.0, (height - 230) * _aspect);
    final h = w / _aspect;
    return Rect.fromLTWH((width - w) / 2 + width * 0.04, height - h, w, h);
  }

  @override
  Rect get nameRect {
    final p = portraitRect;
    final nameH = (width - 24) * 0.36;
    final top = (p.top + p.height * 0.6 - nameH * 0.5).clamp(
      200.0,
      height - nameH - 40,
    );
    return Rect.fromLTWH(12, top, width - 24, nameH);
  }

  @override
  List<Widget> corners(BuildContext context, bool play) {
    final g = gutter(context);
    return [
      Positioned(
        left: g,
        right: g,
        top: 92,
        child: _Delayed(
          play: play,
          delay: 500,
          child: BlendMask(
            blendMode: BlendMode.difference,
            child: _HeroRole(size: fluid(context, 28, 40), alignEnd: false),
          ),
        ),
      ),
      Positioned(
        left: g,
        top: 168,
        child: _Delayed(
          play: play,
          delay: 650,
          child: const BlendMask(
            blendMode: BlendMode.difference,
            child: _HeroLinks(vertical: false),
          ),
        ),
      ),
    ];
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({
    required this.play,
    required this.pointer,
    required this.scrolled,
  });

  final bool play;
  final ValueNotifier<Offset> pointer;
  final double scrolled;

  @override
  Widget build(BuildContext context) {
    // The photo's backdrop is ~#F4F4F4 with faint texture; a slight gain
    // pushes it to pure white so the portrait melts into the hero.
    final image = ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        1.07, 0, 0, 0, 0, //
        0, 1.07, 0, 0, 0, //
        0, 0, 1.07, 0, 0, //
        0, 0, 0, 1, 0,
      ]),
      child: Image.asset(
        AppInfo.portrait,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Portrait of ${AppInfo.name}',
      ),
    );
    if (context.reduceMotion) return image;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: play ? 1 : 0),
      duration: const Duration(milliseconds: 1600),
      curve: AppCurves.expoOut,
      builder: (context, t, child) => ValueListenableBuilder<Offset>(
        valueListenable: pointer,
        child: child,
        builder: (context, p, child) => TweenAnimationBuilder<Offset>(
          tween: Tween(end: p),
          duration: const Duration(milliseconds: 900),
          curve: AppCurves.out,
          child: child,
          builder: (context, sp, child) => Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..translateByDouble(
                sp.dx * -10,
                // Rise in on load, sink slightly while scrolling away.
                (1 - t) * 120 + scrolled * 140,
                0,
                1,
              )
              ..scaleByDouble(
                1.12 - 0.12 * t + scrolled * 0.06,
                1.12 - 0.12 * t + scrolled * 0.06,
                1,
                1,
              ),
            child: child,
          ),
        ),
      ),
      child: image,
    );
  }
}

class _HeroName extends StatelessWidget {
  const _HeroName({
    required this.play,
    required this.pointer,
    required this.scrolled,
  });

  final bool play;
  final ValueNotifier<Offset> pointer;
  final double scrolled;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.heading(
      const TextStyle(
        fontSize: 400,
        height: 1.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -24,
        color: AppColors.paper,
      ),
    );
    final letters = AppInfo.firstName.split('');
    final motion = !context.reduceMotion;

    Widget word = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < letters.length; i++)
          _RisingLetter(
            letter: letters[i],
            style: style,
            play: play || !motion,
            delay: Duration(milliseconds: 60 * i),
          ),
      ],
    );

    word = FittedBox(
      fit: BoxFit.fitWidth,
      alignment: Alignment.centerLeft,
      child: Padding(padding: const EdgeInsets.only(right: 28), child: word),
    );

    if (motion) {
      word = ValueListenableBuilder<Offset>(
        valueListenable: pointer,
        child: word,
        builder: (context, p, child) => TweenAnimationBuilder<Offset>(
          tween: Tween(end: p),
          duration: const Duration(milliseconds: 1100),
          curve: AppCurves.out,
          child: child,
          builder: (context, sp, child) => Transform.translate(
            offset: Offset(sp.dx * 14 - scrolled * 220, -scrolled * 90),
            child: child,
          ),
        ),
      );
    }

    return Semantics(
      header: true,
      label: '${AppInfo.name}, ${AppInfo.role}',
      child: ExcludeSemantics(
        child: BlendMask(blendMode: BlendMode.difference, child: word),
      ),
    );
  }
}

class _RisingLetter extends StatelessWidget {
  const _RisingLetter({
    required this.letter,
    required this.style,
    required this.play,
    required this.delay,
  });

  final String letter;
  final TextStyle style;
  final bool play;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final text = Text(letter, style: style);
    if (context.reduceMotion) return text;
    return ClipRect(
      child: _DelayedTween(
        play: play,
        delay: delay,
        duration: const Duration(milliseconds: 1200),
        curve: AppCurves.power4Out,
        builder: (t, child) => FractionalTranslation(
          translation: Offset(0, 1.05 * (1 - t)),
          child: Transform.rotate(
            angle: (1 - t) * 0.12,
            alignment: Alignment.bottomLeft,
            child: child,
          ),
        ),
        child: text,
      ),
    );
  }
}

/// Tween 0→1 that starts [delay] after [play] turns true.
class _DelayedTween extends StatefulWidget {
  const _DelayedTween({
    required this.play,
    required this.delay,
    required this.duration,
    required this.curve,
    required this.builder,
    required this.child,
  });

  final bool play;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Widget Function(double t, Widget child) builder;
  final Widget child;

  @override
  State<_DelayedTween> createState() => _DelayedTweenState();
}

class _DelayedTweenState extends State<_DelayedTween>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final _curved = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  @override
  void initState() {
    super.initState();
    if (widget.play) _schedule();
  }

  @override
  void didUpdateWidget(covariant _DelayedTween oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) _schedule();
  }

  void _schedule() {
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _curved,
    child: widget.child,
    builder: (context, child) => widget.builder(_curved.value, child!),
  );
}

/// Slides up into place [delay]ms after the intro finishes. Avoids opacity
/// layers so difference blending keeps working.
class _Delayed extends StatelessWidget {
  const _Delayed({
    required this.play,
    required this.delay,
    required this.child,
  });

  final bool play;
  final int delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    return ClipRect(
      child: _DelayedTween(
        play: play,
        delay: Duration(milliseconds: delay),
        duration: const Duration(milliseconds: 1000),
        curve: AppCurves.power4Out,
        builder: (t, child) => FractionalTranslation(
          translation: Offset(0, 1.1 * (1 - t)),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

class _HeroRole extends StatelessWidget {
  const _HeroRole({required this.size, this.alignEnd = true});

  final double size;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.heading(
      TextStyle(
        fontSize: size,
        height: 1.02,
        fontWeight: FontWeight.w600,
        letterSpacing: -size * 0.03,
        color: AppColors.paper,
      ),
    );
    return Text(
      '${AppInfo.role}\n${AppInfo.roleDetail}',
      style: style,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
    );
  }
}

class _HeroLinks extends StatelessWidget {
  const _HeroLinks({required this.vertical});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final links = <(String, VoidCallback)>[
      ('LinkedIn', LinkLauncher.linkedIn),
      if (AppInfo.hasGitHub) ('GitHub', LinkLauncher.gitHub),
      ('Email', LinkLauncher.email),
      ('Resume', LinkLauncher.downloadResume),
    ];
    final children = [
      for (final (label, onTap) in links)
        _ArrowLink(label: label, onTap: onTap),
    ];
    return vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          )
        : Wrap(spacing: 18, children: children);
  }
}

class _ArrowLink extends StatelessWidget {
  const _ArrowLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, hovered) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.label(
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.paper,
                  decoration: hovered ? TextDecoration.underline : null,
                  decorationColor: AppColors.paper,
                ),
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              duration: AppDurations.fast,
              turns: hovered ? 0.125 : 0,
              child: const Icon(
                Icons.north_east_rounded,
                size: 14,
                color: AppColors.paper,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBlurb extends StatelessWidget {
  const _HeroBlurb();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _PulseDot(),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'AVAILABLE FOR NEW PROJECTS',
                style: AppTypography.eyebrow(
                  color: AppColors.textInverse,
                  size: 11.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'I design and ship cross-platform apps in Flutter — '
          'fast, polished and ready for the store.',
          style: AppTypography.body(
            const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 12,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _PulsePainter(_c.value)),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      3 + 6 * t,
      Paint()..color = AppColors.success.withValues(alpha: 0.4 * (1 - t)),
    );
    canvas.drawCircle(c, 3.5, Paint()..color = const Color(0xFF16A34A));
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.t != t;
}

class _ScrollCue extends StatelessWidget {
  const _ScrollCue();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HoverBuilder(
        onTap: () =>
            context.read<NavigationProvider>().scrollTo(AppSection.about),
        semanticLabel: 'Scroll to about',
        builder: (context, hovered) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SCROLL',
              style: AppTypography.eyebrow(
                color: AppColors.textInverse,
                size: 11,
              ),
            ),
            const SizedBox(height: 8),
            const _ScrollLine(),
          ],
        ),
      ),
    );
  }
}

class _ScrollLine extends StatefulWidget {
  const _ScrollLine();

  @override
  State<_ScrollLine> createState() => _ScrollLineState();
}

class _ScrollLineState extends State<_ScrollLine>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.reduceMotion && !_c.isAnimating) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 36,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _LinePainter(_c.value)),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()
      ..color = AppColors.textInverse.withValues(alpha: 0.15);
    canvas.drawRect(Offset.zero & size, track);
    final eased = AppCurves.inOut.transform(t);
    final start = (eased * 1.4 - 0.4).clamp(0.0, 1.0) * size.height;
    final end = (eased * 1.4).clamp(0.0, 1.0) * size.height;
    canvas.drawRect(
      Rect.fromLTRB(0, start, size.width, end),
      Paint()..color = AppColors.textInverse,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.t != t;
}
