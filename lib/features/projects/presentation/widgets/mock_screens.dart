import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/project.dart';
import 'phone_frame.dart';

/// Illustrative, code-drawn app interfaces shown until real screenshots are
/// added. They use neutral placeholder bars instead of fake names, numbers
/// or ratings, and are always captioned as illustrative in the UI.
///
/// Each kind has three variants (index 0–2) for multi-phone compositions.
class MockScreen extends StatelessWidget {
  const MockScreen({super.key, required this.kind, required this.accent, this.variant = 0});

  final MockupKind kind;
  final Color accent;
  final int variant;

  @override
  Widget build(BuildContext context) {
    final v = variant % 3;
    final content = switch (kind) {
      MockupKind.booking => [_BookingList.new, _BookingProfile.new, _Payment.new][v],
      MockupKind.commerce => [_ShopCatalog.new, _ShopProduct.new, _Payment.new][v],
      MockupKind.calling => [_VideoCall.new, _ChatList.new, _VoiceCall.new][v],
      MockupKind.social => [_SocialFeed.new, _ContactsSync.new, _VideoCall.new][v],
    };
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'Inter',
        color: AppColors.textPrimary,
        fontSize: 13,
        decoration: TextDecoration.none,
      ),
      child: ColoredBox(
        color: const Color(0xFF0E0E1A),
        child: content(accent: accent),
      ),
    );
  }
}

/// Builds a phone using real screenshots when available, otherwise a mockup.
Widget buildProjectPhone(Project project, int index, {double width = 240}) {
  if (project.hasScreenshots && project.screenshotsFramed) {
    return FramedScreenshot(
      project.screenshots[index % project.screenshots.length],
      width: width,
      accent: project.accent,
      semanticLabel: '${project.name} screenshot ${index + 1}',
    );
  }
  final screen = project.hasScreenshots
      ? ScreenshotScreen(
          project.screenshots[index % project.screenshots.length],
          semanticLabel: '${project.name} screenshot ${index + 1}',
        )
      : MockScreen(kind: project.mockupKind, accent: project.accent, variant: index);
  return PhoneFrame(screen: screen, width: width, accent: project.accent);
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

class _Bar extends StatelessWidget {
  const _Bar(this.width, {this.height = 8, this.opacity = 0.16, this.color});
  final double width;
  final double height;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(height),
    ),
  );
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(26, 16, 26, 0),
    child: Row(
      children: [
        Text('9:41', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Spacer(),
        Icon(Icons.signal_cellular_alt_rounded, size: 13),
        SizedBox(width: 4),
        Icon(Icons.wifi_rounded, size: 13),
        SizedBox(width: 4),
        Icon(Icons.battery_full_rounded, size: 13),
      ],
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title(this.text, {this.leading, this.trailing});
  final String text;
  final IconData? leading;
  final IconData? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
    child: Row(
      children: [
        if (leading != null) ...[_IconBubble(leading!, size: 32), const SizedBox(width: 12)],
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, height: 1.15),
          ),
        ),
        if (trailing != null) _IconBubble(trailing!, size: 32),
      ],
    ),
  );
}

class _IconBubble extends StatelessWidget {
  const _IconBubble(this.icon, {this.size = 36, this.color, this.iconColor});
  final IconData icon;
  final double size;
  final Color? color;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color ?? Colors.white.withValues(alpha: 0.07),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: size * 0.48, color: iconColor ?? Colors.white70),
  );
}

class _Search extends StatelessWidget {
  const _Search(this.hint, this.accent);
  final String hint;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    height: 42,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    child: Row(
      children: [
        const Icon(Icons.search_rounded, size: 18, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: Colors.white38),
          ),
        ),
        Icon(Icons.tune_rounded, size: 17, color: accent),
      ],
    ),
  );
}

/// Fills the remaining height and clips anything that doesn't fit, so the
/// fixed-size mock screens never overflow (no scrollable involved).
class _ClipList extends StatelessWidget {
  const _ClipList({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Expanded(
    child: ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ),
  );
}

/// Horizontal equivalent of [_ClipList] for rows of chips/avatars.
class _ClipRow extends StatelessWidget {
  const _ClipRow({required this.children, this.height = 34});
  final List<Widget> children;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ClipRect(
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        maxWidth: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.accent, {this.selected = false, this.icon});
  final String label;
  final Color accent;
  final bool selected;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: selected ? accent : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: selected ? Colors.black87 : Colors.white70),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black87 : Colors.white70,
          ),
        ),
      ],
    ),
  );
}

class _CtaButton extends StatelessWidget {
  const _CtaButton(this.label, this.accent);
  final String label;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 26),
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [accent, Color.lerp(accent, AppColors.secondary, 0.55)!]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.accent, {this.size = 44});
  final Color accent;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent.withValues(alpha: 0.9), AppColors.secondary.withValues(alpha: 0.7)],
      ),
    ),
    child: Icon(
      Icons.person_rounded,
      size: size * 0.55,
      color: Colors.white.withValues(alpha: 0.9),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
    ),
    child: child,
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav(this.accent, this.icons);
  final Color accent;
  final List<IconData> icons;
  @override
  Widget build(BuildContext context) => Container(
    height: 62,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < icons.length; i++)
          Icon(icons[i], size: 22, color: i == 0 ? accent : Colors.white38),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Healthcare booking
// ---------------------------------------------------------------------------

class _BookingList extends StatelessWidget {
  const _BookingList({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    const specialties = [
      (Icons.favorite_rounded, 'Cardio'),
      (Icons.visibility_rounded, 'Eye'),
      (Icons.child_care_rounded, 'Child'),
      (Icons.psychology_rounded, 'Neuro'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatusBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Icon(Icons.location_on_rounded, size: 15, color: accent),
              const SizedBox(width: 4),
              const Text('Near you', style: TextStyle(fontSize: 12, color: Colors.white60)),
              const Spacer(),
              const _IconBubble(Icons.notifications_none_rounded, size: 32),
            ],
          ),
        ),
        const _Title('Find your doctor'),
        _Search('Doctor or specialty', accent),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (icon, label) in specialties)
                Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: accent, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.white60)),
                  ],
                ),
            ],
          ),
        ),
        _ClipList(
          children: [
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'Available doctors',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            for (var i = 0; i < 3; i++)
              _Card(
                child: Row(
                  children: [
                    _Avatar(accent, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bar(110 - i * 14.0, height: 9, opacity: 0.5),
                          const SizedBox(height: 7),
                          _Bar(70 + i * 8.0, height: 7, color: accent, opacity: 0.55),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        _BottomNav(accent, const [
          Icons.home_rounded,
          Icons.calendar_month_rounded,
          Icons.chat_bubble_outline_rounded,
          Icons.person_outline_rounded,
        ]),
      ],
    );
  }
}

class _BookingProfile extends StatelessWidget {
  const _BookingProfile({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent.withValues(alpha: 0.35), const Color(0xFF0E0E1A)],
            ),
          ),
          child: Column(
            children: [
              const _StatusBar(),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    _IconBubble(Icons.arrow_back_rounded, size: 32),
                    Spacer(),
                    _IconBubble(Icons.favorite_border_rounded, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _Avatar(accent, size: 92),
              const SizedBox(height: 14),
              const _Bar(130, height: 11, opacity: 0.6),
              const SizedBox(height: 8),
              _Bar(90, height: 8, color: accent, opacity: 0.7),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: Row(
            children: [
              for (final icon in [
                Icons.call_rounded,
                Icons.chat_rounded,
                Icons.location_on_rounded,
              ])
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                ),
            ],
          ),
        ),
        _ClipList(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select a slot',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < 6; i++)
                    Container(
                      width: 78,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == 2 ? accent : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _Bar(40, height: 7, opacity: i == 2 ? 0.0 : 0.25, color: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
        _CtaButton('Book appointment', accent),
      ],
    );
  }
}

class _Payment extends StatelessWidget {
  const _Payment({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    const methods = [
      (Icons.account_balance_wallet_rounded, 'UPI'),
      (Icons.credit_card_rounded, 'Card'),
      (Icons.account_balance_rounded, 'Net banking'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatusBar(),
        const _Title('Checkout', leading: Icons.arrow_back_rounded),
        _ClipList(
          children: [
            _Card(
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          _Bar(90.0 - i * 10, height: 8, opacity: 0.3),
                          const Spacer(),
                          const _Bar(44, height: 8, opacity: 0.45),
                        ],
                      ),
                    ),
                  Divider(color: Colors.white.withValues(alpha: 0.08), height: 20),
                  Row(
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      _Bar(60, height: 10, color: accent, opacity: 0.85),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Text(
                'Payment method',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            for (var i = 0; i < methods.length; i++)
              _Card(
                child: Row(
                  children: [
                    _IconBubble(
                      methods[i].$1,
                      size: 34,
                      iconColor: accent,
                      color: accent.withValues(alpha: 0.12),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      methods[i].$2,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const Spacer(),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == 0 ? accent : Colors.white30,
                          width: i == 0 ? 5 : 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 13, color: accent),
              const SizedBox(width: 6),
              const Text('Secure payment', style: TextStyle(fontSize: 11.5, color: Colors.white54)),
            ],
          ),
        ),
        _CtaButton('Pay now', accent),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Furniture e-commerce
// ---------------------------------------------------------------------------

class _ShopCatalog extends StatelessWidget {
  const _ShopCatalog({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    const items = [
      Icons.chair_rounded,
      Icons.weekend_rounded,
      Icons.bed_rounded,
      Icons.table_restaurant_rounded,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatusBar(),
        const _Title('Discover\nyour space', trailing: Icons.shopping_bag_outlined),
        _Search('Search furniture', accent),
        const SizedBox(height: 14),
        _ClipRow(
          children: [
            _Pill('All', accent, selected: true),
            const SizedBox(width: 8),
            _Pill('Chairs', accent, icon: Icons.chair_alt_rounded),
            const SizedBox(width: 8),
            _Pill('Sofas', accent, icon: Icons.weekend_outlined),
            const SizedBox(width: 8),
            _Pill('Beds', accent, icon: Icons.bed_outlined),
          ],
        ),
        const SizedBox(height: 14),
        _ClipList(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Container(
                      width: 125,
                      height: 160,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.045),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    accent.withValues(alpha: 0.28),
                                    accent.withValues(alpha: 0.04),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(items[i], size: 48, color: accent),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Bar(80.0 - i * 6, height: 8, opacity: 0.5),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _Bar(40, height: 7, color: accent, opacity: 0.7),
                              const Spacer(),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        _BottomNav(accent, const [
          Icons.home_rounded,
          Icons.grid_view_rounded,
          Icons.favorite_border_rounded,
          Icons.person_outline_rounded,
        ]),
      ],
    );
  }
}

class _ShopProduct extends StatelessWidget {
  const _ShopProduct({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 340,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.1),
              radius: 0.8,
              colors: [accent.withValues(alpha: 0.32), const Color(0xFF0E0E1A)],
            ),
          ),
          child: Column(
            children: [
              const _StatusBar(),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    _IconBubble(Icons.arrow_back_rounded, size: 32),
                    Spacer(),
                    _IconBubble(Icons.favorite_border_rounded, size: 32),
                  ],
                ),
              ),
              Expanded(child: Icon(Icons.chair_rounded, size: 170, color: accent)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: i == 0 ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == 0 ? accent : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        _ClipList(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _Bar(170, height: 13, opacity: 0.6),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: _Bar(70, height: 10, color: accent, opacity: 0.8),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bar(250, height: 6, opacity: 0.12),
                  SizedBox(height: 7),
                  _Bar(230, height: 6, opacity: 0.12),
                  SizedBox(height: 7),
                  _Bar(160, height: 6, opacity: 0.12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  for (final c in [accent, const Color(0xFF8B8B9E), const Color(0xFF5C4033)])
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: c == accent ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        _CtaButton('Add to cart', accent),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Real-time communication
// ---------------------------------------------------------------------------

class _CallControls extends StatelessWidget {
  const _CallControls({required this.video});
  final bool video;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const _IconBubble(
          Icons.mic_off_rounded,
          size: 52,
          color: Color(0x33FFFFFF),
          iconColor: Colors.white,
        ),
        _IconBubble(
          video ? Icons.videocam_rounded : Icons.volume_up_rounded,
          size: 52,
          color: const Color(0x33FFFFFF),
          iconColor: Colors.white,
        ),
        if (video)
          const _IconBubble(
            Icons.cameraswitch_rounded,
            size: 52,
            color: Color(0x33FFFFFF),
            iconColor: Colors.white,
          ),
        const _IconBubble(
          Icons.call_end_rounded,
          size: 60,
          color: Color(0xFFEF4444),
          iconColor: Colors.white,
        ),
      ],
    ),
  );
}

class _VideoCall extends StatelessWidget {
  const _VideoCall({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.55),
            AppColors.secondary.withValues(alpha: 0.45),
            const Color(0xFF0E0E1A),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.person_rounded,
              size: 230,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Column(
            children: [
              const _StatusBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Bar(100, height: 11, opacity: 0.75),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const _Bar(46, height: 7, opacity: 0.5),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 86,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C30),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 54,
                        color: accent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const _CallControls(video: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoiceCall extends StatelessWidget {
  const _VoiceCall({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1,
          colors: [accent.withValues(alpha: 0.35), const Color(0xFF0E0E1A)],
        ),
      ),
      child: Column(
        children: [
          const _StatusBar(),
          const SizedBox(height: 70),
          Stack(
            alignment: Alignment.center,
            children: [
              for (final s in [210.0, 165.0])
                Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withValues(alpha: s == 210 ? 0.15 : 0.3)),
                  ),
                ),
              _Avatar(accent, size: 120),
            ],
          ),
          const SizedBox(height: 26),
          const _Bar(130, height: 12, opacity: 0.7),
          const SizedBox(height: 12),
          Text(
            'Audio call',
            style: TextStyle(fontSize: 13, color: accent, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const _CallControls(video: false),
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StatusBar(),
            const SizedBox(height: 56),
            const _Title('Chats', trailing: Icons.edit_outlined),
            _Search('Search', accent),
            const SizedBox(height: 10),
            _ClipList(
              children: [
                for (var i = 0; i < 6; i++)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Row(
                      children: [
                        _Avatar(i.isEven ? accent : AppColors.highlight, size: 42),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bar(100.0 - (i % 3) * 14, height: 9, opacity: 0.55),
                              const SizedBox(height: 7),
                              _Bar(150.0 - (i % 2) * 30, height: 7, opacity: 0.16),
                            ],
                          ),
                        ),
                        if (i < 2)
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        // Push notification banner.
        Positioned(
          left: 12,
          right: 12,
          top: 42,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF23233A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                _IconBubble(
                  Icons.videocam_rounded,
                  size: 34,
                  color: accent,
                  iconColor: Colors.black87,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incoming video call',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 5),
                      _Bar(90, height: 6, opacity: 0.3),
                    ],
                  ),
                ),
                const _IconBubble(
                  Icons.call_end_rounded,
                  size: 28,
                  color: Color(0xFFEF4444),
                  iconColor: Colors.white,
                ),
                const SizedBox(width: 6),
                const _IconBubble(
                  Icons.call_rounded,
                  size: 28,
                  color: Color(0xFF22C55E),
                  iconColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Social
// ---------------------------------------------------------------------------

class _SocialFeed extends StatelessWidget {
  const _SocialFeed({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatusBar(),
        const _Title('Friends', trailing: Icons.person_add_alt_rounded),
        SizedBox(
          height: 78,
          child: _ClipRow(
            height: 78,
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [accent, AppColors.secondary]),
                        ),
                        child: _Avatar(i.isEven ? accent : AppColors.highlight, size: 44),
                      ),
                      const SizedBox(height: 6),
                      const _Bar(34, height: 6, opacity: 0.3),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _ClipList(
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Avatar(accent, size: 34),
                      const SizedBox(width: 10),
                      const _Bar(90, height: 8, opacity: 0.5),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.5),
                          AppColors.secondary.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.play_circle_fill_rounded,
                      size: 44,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 19, color: accent),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.share_rounded, size: 18, color: Colors.white60),
                      const Spacer(),
                      const Icon(Icons.videocam_outlined, size: 20, color: Colors.white60),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        _BottomNav(accent, const [
          Icons.home_rounded,
          Icons.call_outlined,
          Icons.add_box_outlined,
          Icons.person_outline_rounded,
        ]),
      ],
    );
  }
}

class _ContactsSync extends StatelessWidget {
  const _ContactsSync({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatusBar(),
        const _Title('Contacts', leading: Icons.arrow_back_rounded),
        _Card(
          child: Row(
            children: [
              _IconBubble(
                Icons.sync_rounded,
                size: 38,
                color: accent.withValues(alpha: 0.15),
                iconColor: accent,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contacts synced',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    SizedBox(height: 5),
                    _Bar(110, height: 6, opacity: 0.25),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: accent, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _ClipList(
          children: [
            for (var i = 0; i < 6; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    _Avatar(i.isEven ? accent : AppColors.highlight, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _Bar(110.0 - (i % 3) * 16, height: 9, opacity: 0.5),
                      ),
                    ),
                    Icon(Icons.call_outlined, size: 19, color: accent),
                    const SizedBox(width: 16),
                    Icon(Icons.videocam_outlined, size: 20, color: accent),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
