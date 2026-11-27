import 'dart:ui';

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
import '../../../../shared/animations/magnetic.dart';
import '../../../../shared/animations/roll_text.dart';
import '../providers/navigation_provider.dart';

/// Fixed header. Transparent with dark ink over the white hero; a blurred
/// dark bar with light ink afterwards. Slides away while scrolling down.
class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final light = nav.pastHero || nav.menuOpen;
    final ink = light ? AppColors.textPrimary : AppColors.textInverse;
    final g = gutter(context);
    final desktop = context.isDesktop;

    final bar = AnimatedContainer(
      duration: AppDurations.medium,
      curve: AppCurves.out,
      height: desktop ? 76 : 64,
      padding: EdgeInsets.symmetric(horizontal: g),
      color: nav.pastHero && !nav.menuOpen
          ? AppColors.background.withValues(alpha: 0.72)
          : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _Brand(
                ink: ink,
                onTap: () => nav.scrollTo(AppSection.home),
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (desktop) ...[
            for (final s in AppSection.navItems.where(
              (s) => s != AppSection.home && s != AppSection.contact,
            ))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _NavLink(
                  label: s.label,
                  ink: ink,
                  active: nav.activeSection == s,
                  onTap: () => nav.scrollTo(s),
                ),
              ),
            const SizedBox(width: 18),
            Magnetic(
              strength: 0.25,
              child: _NavCta(
                light: light,
                onTap: () => nav.scrollTo(AppSection.contact),
              ),
            ),
          ] else
            _MenuButton(
              ink: ink,
              open: nav.menuOpen,
              onTap: () => nav.setMenuOpen(!nav.menuOpen),
            ),
        ],
      ),
    );

    final blurred = nav.pastHero && !nav.menuOpen
        ? ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: bar,
            ),
          )
        : bar;

    return AnimatedSlide(
      duration: AppDurations.medium,
      curve: AppCurves.out,
      offset: nav.navHidden ? const Offset(0, -1.2) : Offset.zero,
      child: blurred,
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.ink, required this.onTap});

  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: '${AppInfo.name} — back to top',
      builder: (context, hovered) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppDurations.medium,
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: ink),
            child: AnimatedRotation(
              duration: AppDurations.slow,
              curve: AppCurves.spring,
              turns: hovered ? 1 : 0,
              child: Text(
                AppInfo.initials,
                style: AppTypography.wordmark(
                  TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ink == AppColors.textPrimary
                        ? AppColors.textInverse
                        : AppColors.paper,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (MediaQuery.sizeOf(context).width >= 380)
            Flexible(
              child: RollText(
                MediaQuery.sizeOf(context).width < 600
                    ? AppInfo.firstName
                    : AppInfo.shortName,
                active: hovered,
                style: AppTypography.label(
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: ink,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.ink,
    required this.active,
    required this.onTap,
  });

  final String label;
  final Color ink;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, hovered) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RollText(
            label,
            active: hovered,
            style: AppTypography.label(
              TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: ink),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: AppDurations.medium,
            curve: AppCurves.out,
            height: 1,
            width: active ? 18 : 0,
            color: ink,
          ),
        ],
      ),
    );
  }
}

class _NavCta extends StatelessWidget {
  const _NavCta({required this.light, required this.onTap});

  final bool light;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: "Let's talk",
      builder: (context, hovered) => AnimatedContainer(
        duration: AppDurations.medium,
        padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
        decoration: BoxDecoration(
          color: light ? AppColors.cream : AppColors.textInverse,
          borderRadius: AppRadius.button,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RollText(
              "Let's talk",
              active: hovered,
              style: AppTypography.label(
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: light ? AppColors.textInverse : AppColors.paper,
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: AppDurations.medium,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: light ? AppColors.background : AppColors.paper,
              ),
              child: AnimatedRotation(
                duration: AppDurations.medium,
                curve: AppCurves.spring,
                turns: hovered ? 0.125 : 0,
                child: Icon(
                  Icons.north_east_rounded,
                  size: 15,
                  color: light ? AppColors.textPrimary : AppColors.textInverse,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.ink,
    required this.open,
    required this.onTap,
  });

  final Color ink;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: open ? 'Close menu' : 'Open menu',
      builder: (context, hovered) => SizedBox(
        height: 48,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Text(
                open ? 'Close' : 'Menu',
                key: ValueKey(open),
                style: AppTypography.label(
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: AppDurations.medium,
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: ink),
              child: AnimatedRotation(
                duration: AppDurations.medium,
                curve: AppCurves.spring,
                turns: open ? 0.125 : 0,
                child: Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: ink == AppColors.textPrimary
                      ? AppColors.textInverse
                      : AppColors.paper,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen menu: numbered links that rise in one by one, then contact
/// details. Drops in like a curtain from the top.
class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final open = nav.menuOpen;
    final g = gutter(context);
    final items = AppSection.navItems;

    void go(AppSection s) {
      nav.setMenuOpen(false);
      Future<void>.delayed(
        const Duration(milliseconds: 380),
        () => nav.scrollTo(s),
      );
    }

    return IgnorePointer(
      ignoring: !open,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: open ? 1 : 0),
        duration: const Duration(milliseconds: 800),
        curve: AppCurves.inOut,
        builder: (context, t, child) => ClipRect(
          clipper: _CurtainClipper(t),
          child: t == 0 ? const SizedBox.shrink() : child,
        ),
        child: Material(
          color: AppColors.background,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(g, 88, g, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            _MenuItem(
                              index: i,
                              open: open,
                              section: items[i],
                              active: nav.activeSection == items[i],
                              onTap: () => go(items[i]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Stagger(
                    open: open,
                    index: items.length + 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HoverBuilder(
                          onTap: LinkLauncher.email,
                          semanticLabel: 'Email ${AppInfo.email}',
                          builder: (context, h) => Text(
                            AppInfo.email,
                            style: AppTypography.heading(
                              const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: AppColors.textPrimary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 20,
                          runSpacing: 8,
                          children: [
                            _SmallLink('LinkedIn', LinkLauncher.linkedIn),
                            if (AppInfo.hasGitHub)
                              _SmallLink('GitHub', LinkLauncher.gitHub),
                            _SmallLink('Phone', LinkLauncher.phone),
                            _SmallLink('Resume', LinkLauncher.downloadResume),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Start a project',
                          icon: Icons.north_east_rounded,
                          onPressed: () => go(AppSection.contact),
                        ),
                      ],
                    ),
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

class _CurtainClipper extends CustomClipper<Rect> {
  _CurtainClipper(this.t);

  final double t;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width, size.height * t);

  @override
  bool shouldReclip(_CurtainClipper old) => old.t != t;
}

class _Stagger extends StatelessWidget {
  const _Stagger({
    required this.open,
    required this.index,
    required this.child,
  });

  final bool open;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: Duration(milliseconds: 700 + index * 60),
      curve: AppCurves.power4Out,
      offset: open ? Offset.zero : const Offset(0, 0.6),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 500 + index * 60),
        opacity: open ? 1 : 0,
        child: child,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.index,
    required this.open,
    required this.section,
    required this.active,
    required this.onTap,
  });

  final int index;
  final bool open;
  final AppSection section;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Stagger(
      open: open,
      index: index,
      child: HoverBuilder(
        onTap: onTap,
        semanticLabel: section.label,
        builder: (context, hovered) => Container(
          decoration: BoxDecoration(
            border: index == 0
                ? null
                : const Border(top: BorderSide(color: AppColors.borderStrong)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: AppTypography.eyebrow(
                    color: active ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: AnimatedPadding(
                  duration: AppDurations.medium,
                  curve: AppCurves.out,
                  padding: EdgeInsets.only(left: hovered ? 12 : 0),
                  child: Text(
                    section.label,
                    style: AppTypography.heading(
                      TextStyle(
                        fontSize: fluid(context, 40, 64),
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.6,
                        color: hovered || active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedRotation(
                duration: AppDurations.medium,
                turns: hovered ? 0.125 : 0,
                child: Icon(
                  Icons.north_east_rounded,
                  color: active ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: h ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
