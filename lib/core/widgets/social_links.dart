import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../shared/animations/hover_builder.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_info.dart';
import '../utils/link_launcher.dart';

/// LinkedIn, GitHub (only when configured) and Email icon buttons.
class SocialLinks extends StatelessWidget {
  const SocialLinks({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        SocialIconButton(
          icon: FontAwesomeIcons.linkedinIn.data,
          tooltip: 'LinkedIn',
          onTap: LinkLauncher.linkedIn,
          size: size,
        ),
        if (AppInfo.hasGitHub)
          SocialIconButton(
            icon: FontAwesomeIcons.github.data,
            tooltip: 'GitHub',
            onTap: LinkLauncher.gitHub,
            size: size,
          ),
        SocialIconButton(
          icon: Icons.alternate_email_rounded,
          tooltip: 'Email',
          onTap: LinkLauncher.email,
          size: size,
        ),
      ],
    );
  }
}

class SocialIconButton extends StatelessWidget {
  const SocialIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 44,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: HoverBuilder(
        onTap: onTap,
        semanticLabel: tooltip,
        builder: (context, hovered) => AnimatedContainer(
          duration: AppDurations.fast,
          width: size,
          height: size,
          transform: Matrix4.translationValues(0, hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hovered
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.card.withValues(alpha: 0.6),
            border: Border.all(
              color: hovered ? AppColors.highlight : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: size * 0.38,
            color: hovered ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
