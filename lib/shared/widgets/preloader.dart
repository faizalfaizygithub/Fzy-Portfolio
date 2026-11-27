import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_info.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/editorial.dart';

/// Opening sequence: a counter runs to 100 while the portrait loads, then
/// two curtains lift (dark, then charcoal) to reveal the page.
///
/// [onReveal] fires as the curtains start lifting, [onFinished] once they
/// are gone and the overlay can be removed.
class Preloader extends StatefulWidget {
  const Preloader({
    super.key,
    required this.onReveal,
    required this.onFinished,
  });

  final VoidCallback onReveal;
  final VoidCallback onFinished;

  @override
  State<Preloader> createState() => _PreloaderState();
}

class _PreloaderState extends State<Preloader> with TickerProviderStateMixin {
  late final _count = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );
  late final _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  static const _words = ['Flutter', 'Dart', 'Firebase', 'Motion', 'Craft'];
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _count.addStatusListener((status) {
      if (status == AnimationStatus.completed) _leave();
    });
    _exit.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onFinished();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // Start counting once the portrait is ready (or after a short cap), so
    // the hero never reveals an empty frame.
    final ready = precacheImage(
      const AssetImage(AppInfo.portrait),
      context,
    ).timeout(const Duration(seconds: 3), onTimeout: () {});
    Future.wait([
      ready,
      Future<void>.delayed(const Duration(milliseconds: 200)),
    ]).whenComplete(() {
      if (mounted) _count.forward();
    });
  }

  void _leave() {
    widget.onReveal();
    _exit.forward();
  }

  @override
  void dispose() {
    _count.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final g = gutter(context);
    final counterStyle = AppTypography.numeric(
      TextStyle(
        fontSize: fluid(context, 112, 220),
        height: 0.9,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    final darkCurtain = CurvedAnimation(
      parent: _exit,
      curve: const Interval(0, 0.75, curve: AppCurves.inOut),
    );
    final greyCurtain = CurvedAnimation(
      parent: _exit,
      curve: const Interval(0.14, 0.95, curve: AppCurves.inOut),
    );

    return IgnorePointer(
      ignoring: _exit.isCompleted,
      child: Stack(
        children: [
          // Trailing curtain.
          AnimatedBuilder(
            animation: greyCurtain,
            builder: (context, _) => Positioned(
              left: 0,
              right: 0,
              top: -size.height * greyCurtain.value,
              height: size.height,
              child: const ColoredBox(color: AppColors.raised),
            ),
          ),
          // Leading curtain with content.
          AnimatedBuilder(
            animation: darkCurtain,
            builder: (context, child) => Positioned(
              left: 0,
              right: 0,
              top: -size.height * darkCurtain.value,
              height: size.height,
              child: child!,
            ),
            child: ColoredBox(
              color: AppColors.background,
              child: Padding(
                padding: EdgeInsets.fromLTRB(g, 32, g, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppInfo.name.toUpperCase(),
                            style: AppTypography.eyebrow(),
                          ),
                        ),
                        Text(
                          'PORTFOLIO ©${AppInfo.copyrightYear}',
                          style: AppTypography.eyebrow(),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _count,
                          builder: (context, _) {
                            final i = (_count.value * _words.length)
                                .floor()
                                .clamp(0, _words.length - 1);
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              transitionBuilder: (child, a) => FadeTransition(
                                opacity: a,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0, 0.4),
                                    end: Offset.zero,
                                  ).animate(a),
                                  child: child,
                                ),
                              ),
                              child: Text(
                                _words[i],
                                key: ValueKey(i),
                                style: AppTypography.heading(
                                  TextStyle(
                                    fontSize: fluid(context, 22, 30),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.6,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _count,
                      builder: (context, _) {
                        final v = Curves.easeInOutCubic.transform(_count.value);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Loading\nthe experience',
                                    style: AppTypography.body(
                                      const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  (v * 100).round().toString().padLeft(3, '0'),
                                  style: counterStyle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: v,
                                child: Container(
                                  height: 1,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
