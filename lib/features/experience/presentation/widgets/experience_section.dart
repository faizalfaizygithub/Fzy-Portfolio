import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/animations/line_reveal.dart';
import '../../../../shared/animations/reveal.dart';
import '../../data/experience_data.dart';

/// Experience as big editorial rows. Hover wipes a cream panel up behind the
/// row and inverts it; tapping expands what I did there.
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ExperienceData.items;
    return Section(
      top: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: AppSpacing.lg,
            spacing: AppSpacing.xl,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SectionLabel('Experience', index: '02'),
                  const SizedBox(height: AppSpacing.lg),
                  LineReveal(
                    lines: const ["Where I've been", 'building lately.'],
                    lineColors: const [null, AppColors.textMuted],
                    style: AppTypography.display(fluid(context, 36, 64)),
                  ),
                ],
              ),
              Reveal(
                child: Text(
                  '${items.length.toString().padLeft(2, '0')} ROLES — TAP TO EXPAND',
                  style: AppTypography.eyebrow(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          SizedBox(height: fluid(context, 40, 64)),
          const HairlineDivider(),
          for (var i = 0; i < items.length; i++)
            Reveal.staggered(
              index: i,
              offset: const Offset(0, 0.2),
              child: _ExperienceRow(index: i, item: items[i]),
            ),
        ],
      ),
    );
  }
}

class _ExperienceRow extends StatefulWidget {
  const _ExperienceRow({required this.index, required this.item});

  final int index;
  final Experience item;

  @override
  State<_ExperienceRow> createState() => _ExperienceRowState();
}

class _ExperienceRowState extends State<_ExperienceRow> {
  late bool _open = widget.index == 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final wide = !context.isMobile;

    return HoverBuilder(
      onTap: () => setState(() => _open = !_open),
      semanticLabel:
          '${item.company}, ${item.role}. ${_open ? 'Collapse' : 'Expand'}',
      builder: (context, hovered) {
        final ink = hovered ? AppColors.textInverse : AppColors.textPrimary;
        final sub = hovered ? const Color(0xFF4A4A4A) : AppColors.textSecondary;

        final title = Text(
          item.company,
          style: AppTypography.heading(
            TextStyle(
              fontSize: fluid(context, 24, 44),
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.2,
              color: ink,
            ),
          ),
        );
        final meta = Text(
          '${item.role} · ${item.location}',
          style: AppTypography.body(TextStyle(fontSize: 15, color: sub)),
        );
        final period = Text(
          item.period.toUpperCase(),
          style: AppTypography.eyebrow(color: sub),
        );

        return Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
          ),
          child: Stack(
            children: [
              // Cream wipe.
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 550),
                    curve: AppCurves.inOut,
                    heightFactor: hovered ? 1 : 0,
                    widthFactor: 1,
                    child: const ColoredBox(color: AppColors.cream),
                  ),
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 550),
                curve: AppCurves.inOut,
                padding: EdgeInsets.symmetric(
                  vertical: fluid(context, 24, 36),
                  horizontal: hovered ? fluid(context, 16, 28) : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: wide ? 72 : 44,
                          child: Text(
                            (widget.index + 1).toString().padLeft(2, '0'),
                            style: AppTypography.numeric(
                              TextStyle(
                                fontSize: wide ? 28 : 22,
                                fontWeight: FontWeight.w600,
                                color: hovered
                                    ? AppColors.textInverse
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: title),
                                  if (item.current) ...[
                                    const SizedBox(width: 14),
                                    _NowBadge(inverse: hovered),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              meta,
                              if (!wide) ...[const SizedBox(height: 8), period],
                            ],
                          ),
                        ),
                        if (wide) ...[const SizedBox(width: 24), period],
                        const SizedBox(width: 20),
                        AnimatedRotation(
                          duration: AppDurations.medium,
                          curve: AppCurves.spring,
                          turns: _open ? 0.125 : 0,
                          child: Icon(Icons.add_rounded, color: ink, size: 26),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 600),
                      curve: AppCurves.inOut,
                      alignment: Alignment.topCenter,
                      child: _open
                          ? Padding(
                              padding: EdgeInsets.only(
                                top: AppSpacing.lg,
                                left: wide ? 72 : 0,
                              ),
                              child: _Responsibilities(
                                items: item.responsibilities,
                                ink: ink,
                                sub: sub,
                                columns: context.isDesktop ? 2 : 1,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Responsibilities extends StatelessWidget {
  const _Responsibilities({
    required this.items,
    required this.ink,
    required this.sub,
    required this.columns,
  });

  final List<String> items;
  final Color ink;
  final Color sub;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 32 * (columns - 1)) / columns;
        return Wrap(
          spacing: 32,
          runSpacing: 12,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 34,
                      child: Text(
                        (i + 1).toString().padLeft(2, '0'),
                        style: AppTypography.eyebrow(color: sub, size: 11),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        items[i],
                        style: AppTypography.body(
                          TextStyle(fontSize: 15, height: 1.5, color: ink),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NowBadge extends StatelessWidget {
  const _NowBadge({required this.inverse});

  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final fg = inverse ? AppColors.textInverse : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppRadius.button,
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 6),
          Text('NOW', style: AppTypography.eyebrow(color: fg, size: 10.5)),
        ],
      ),
    );
  }
}
