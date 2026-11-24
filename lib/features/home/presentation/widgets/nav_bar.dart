import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_sections.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/animations/hover_builder.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../providers/navigation_provider.dart';

/// Floating glass navigation bar. Becomes more opaque once the page scrolls.
class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final scrolled = context.select<NavigationProvider, bool>((n) => n.isScrolled);
    final mobile = !context.isDesktop;
    final height = mobile ? AppSizes.navHeightMobile : AppSizes.navHeight;

    final bar = AnimatedContainer(
      duration: AppDurations.medium,
      curve: AppCurves.smooth,
      height: height,
      margin: EdgeInsets.symmetric(
        horizontal: scrolled ? context.horizontalPadding * 0.5 : 0,
        vertical: scrolled ? AppSpacing.sm : 0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scrolled ? AppSpacing.lg : context.horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: scrolled ? 0.72 : 0),
        borderRadius: BorderRadius.circular(scrolled ? AppRadius.pill : 0),
        border: Border.all(
          color: scrolled ? AppColors.border.withValues(alpha: 0.8) : Colors.transparent,
        ),
        boxShadow: scrolled
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 30)]
            : null,
      ),
      child: Row(
        children: [
          BrandLogo(onTap: nav.scrollToTop, size: mobile ? 36 : 40),
          const Spacer(),
          if (!mobile) ...[
            const _NavItems(),
            const SizedBox(width: AppSpacing.lg),
            const AppButton(
              label: 'Resume',
              icon: Icons.download_rounded,
              variant: AppButtonVariant.outline,
              compact: true,
              onPressed: LinkLauncher.downloadResume,
            ),
          ] else
            _MenuButton(onTap: onOpenMenu),
        ],
      ),
    );

    // Entrance: fade + slide down on first build. No controller needed.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: context.reduceMotion ? 1 : 0, end: 1),
      duration: AppDurations.slow,
      curve: AppCurves.emphasized,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, -24 * (1 - t)), child: child),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth + 160),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(scrolled ? AppRadius.pill : 0),
            child: BackdropFilter(
              enabled: scrolled,
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: bar,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItems extends StatelessWidget {
  const _NavItems();

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final active = context.select<NavigationProvider, AppSection>((n) => n.activeSection);
    return Row(
      children: [
        for (final section in AppSection.navItems)
          _NavItem(
            label: section.label,
            active: section == active,
            onTap: () => nav.scrollTo(section),
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium!;
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: 'Go to $label',
      builder: (context, hovered) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              style: style.copyWith(
                fontSize: 14,
                color: active || hovered ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: AppDurations.medium,
              curve: AppCurves.emphasized,
              height: 2,
              width: active ? 18 : (hovered ? 8 : 0),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: AppRadius.button,
                boxShadow: active
                    ? const [BoxShadow(color: AppColors.primary, blurRadius: 8)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      semanticLabel: 'Open navigation menu',
      builder: (context, hovered) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hovered ? AppColors.card : AppColors.card.withValues(alpha: 0.6),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}

/// Mobile/tablet navigation drawer.
class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final active = context.select<NavigationProvider, AppSection>((n) => n.activeSection);
    final theme = Theme.of(context).textTheme;

    void go(AppSection section) {
      Navigator.of(context).pop();
      nav.scrollTo(section);
    }

    return Drawer(
      width: 320,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  BrandLogo(onTap: () => go(AppSection.home), size: 36),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close menu',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < AppSection.navItems.length; i++)
                _DrawerItem(
                  index: i,
                  label: AppSection.navItems[i].label,
                  active: AppSection.navItems[i] == active,
                  onTap: () => go(AppSection.navItems[i]),
                ),
              const Spacer(),
              const AppButton(
                label: 'Download Resume',
                icon: Icons.download_rounded,
                expand: true,
                onPressed: LinkLauncher.downloadResume,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Available for opportunities',
                textAlign: TextAlign.center,
                style: theme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.index,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    // Items cascade in when the drawer opens.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.medium + AppDurations.stagger * index,
      curve: AppCurves.emphasized,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(24 * (1 - t), 0), child: child),
      ),
      child: HoverBuilder(
        onTap: onTap,
        semanticLabel: label,
        builder: (context, hovered) => AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: active || hovered ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: active ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Text(
                '0${index + 1}',
                style: theme.labelSmall?.copyWith(
                  color: active ? AppColors.highlight : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(label, style: theme.headlineSmall?.copyWith(fontSize: 22)),
            ],
          ),
        ),
      ),
    );
  }
}
