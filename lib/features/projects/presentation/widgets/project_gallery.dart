import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/reveal.dart';
import '../../domain/project.dart';
import 'mock_screens.dart';

/// Screens gallery for the detail page.
///
/// Wide screens: all phones in a row with hover lift.
/// Narrow screens: a swipeable carousel where off-centre phones shrink.
class ProjectGallery extends StatelessWidget {
  const ProjectGallery({super.key, required this.project});

  final Project project;

  int get _count => project.hasScreenshots ? project.screenshots.length : 3;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile || _count > 6) {
      return _Carousel(project: project, count: _count);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.lg;
        final available = constraints.maxWidth - AppSpacing.xl * 2;
        final width = ((available - gap * (_count - 1)) / _count).clamp(
          140.0,
          250.0,
        );
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: AppSpacing.xl,
          children: [
            for (var i = 0; i < _count; i++)
              Reveal.staggered(
                index: i,
                offset: const Offset(0, 0.1),
                child: HoverBuilder(
                  builder: (context, hovered) => AnimatedContainer(
                    duration: AppDurations.medium,
                    curve: AppCurves.smooth,
                    transform: Matrix4.translationValues(
                      0,
                      hovered ? -12 : 0,
                      0,
                    ),
                    child: buildProjectPhone(project, i, width: width),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({required this.project, required this.count});

  final Project project;
  final int count;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final _controller = PageController(viewportFraction: 0.68);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: AppDurations.medium,
    curve: AppCurves.smooth,
  );

  @override
  Widget build(BuildContext context) {
    const phoneWidth = 220.0;
    const height = phoneWidth * 650 / 300 + AppSpacing.lg;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.count,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (context, i) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                var distance = (i - _page).abs().toDouble();
                if (_controller.position.haveDimensions) {
                  distance = ((_controller.page ?? 0) - i).abs();
                }
                final scale = 1 - (distance.clamp(0, 1) * 0.14);
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: 1 - distance.clamp(0, 1) * 0.45,
                    child: child,
                  ),
                );
              },
              child: Center(
                child: buildProjectPhone(widget.project, i, width: phoneWidth),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(
              icon: Icons.chevron_left_rounded,
              label: 'Previous screen',
              onTap: _page > 0 ? () => _goTo(_page - 1) : null,
            ),
            const SizedBox(width: AppSpacing.md),
            for (var i = 0; i < widget.count; i++)
              AnimatedContainer(
                duration: AppDurations.fast,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _page ? widget.project.accent : AppColors.border,
                  borderRadius: AppRadius.button,
                ),
              ),
            const SizedBox(width: AppSpacing.md),
            _ArrowButton(
              icon: Icons.chevron_right_rounded,
              label: 'Next screen',
              onTap: _page < widget.count - 1 ? () => _goTo(_page + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, hovered) => AnimatedContainer(
        duration: AppDurations.fast,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hovered ? AppColors.card : Colors.transparent,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: onTap == null ? AppColors.textMuted : AppColors.textPrimary,
        ),
      ),
    );
  }
}
