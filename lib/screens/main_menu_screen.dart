import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/menu_action_button.dart';
import '../widgets/menu_info_card.dart';
import 'create_room_screen.dart';
import 'how_to_play_screen.dart';
import 'join_room_screen.dart';
import 'local_play_setup_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    final premium = AppColors.isPremium;
    return Scaffold(
      body: DecoratedBox(
        // Premium theme: the cinematic space scene is already painted
        // behind everything by MaterialApp.builder — just dim it a touch
        // here for text legibility. Classic: plain flat gradient, as
        // before.
        decoration: premium
            ? BoxDecoration(color: Colors.black.withValues(alpha: 0.22))
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.background, AppColors.backgroundGradientEnd],
                ),
              ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    _IconCircleButton(
                      icon: Icons.settings_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const _TitleBlock(),
                const Spacer(),
                MenuActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  title: t.createRoomTitle,
                  subtitle: t.createRoomSubtitle,
                  color: AppColors.blue,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                MenuActionButton(
                  icon: Icons.meeting_room_rounded,
                  title: t.joinRoomTitle,
                  subtitle: t.joinRoomSubtitle,
                  color: AppColors.green,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const JoinRoomScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                MenuActionButton(
                  icon: Icons.people_alt_rounded,
                  title: t.samePhoneTitle,
                  subtitle: t.samePhoneSubtitle,
                  color: AppColors.orange,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LocalPlaySetupScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: MenuInfoCard(
                      icon: Icons.info_outline_rounded,
                      title: t.howToPlayTitle,
                      subtitle: t.howToPlaySubtitle,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HowToPlayScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const BannerAdSlot(),
                Text(
                  'v1.0.0',
                  style: AppTheme.body(
                    12,
                    color: premium ? AppColors.textDisabled : AppColors.textMuted,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    final premium = AppColors.isPremium;
    final titleSize = premium ? 42.0 : 40.0;
    final letterSpacing = premium ? 1.2 : null;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -22,
              child: Icon(
                Icons.emoji_events,
                color: AppColors.gold,
                size: 26,
                shadows: premium ? AppTheme.glow(AppColors.gold, blur: 14) : null,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: AppColors.blue, size: 8),
                const SizedBox(width: 6),
                Text(
                  t.appTitleLine1,
                  style: AppTheme.display(
                    titleSize,
                    color: Colors.white,
                    letterSpacing: letterSpacing,
                    shadows: premium ? AppTheme.glow(AppColors.glow, blur: 22) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.appTitleLine2,
              style: AppTheme.display(
                titleSize,
                color: AppColors.gold,
                letterSpacing: letterSpacing,
                shadows: premium ? AppTheme.glow(AppColors.gold, blur: 22) : null,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.circle, color: AppColors.red, size: 8),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          t.appTagline,
          style: AppTheme.body(
            premium ? 14.5 : 14,
            color: AppColors.textSecondary,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final premium = AppColors.isPremium;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: premium ? const Color(0xFF12283F).withValues(alpha: 0.6) : AppColors.surface,
        border: premium
            ? Border.all(color: AppColors.glow.withValues(alpha: 0.35))
            : null,
        boxShadow: premium
            ? [
                BoxShadow(
                  color: AppColors.glow.withValues(alpha: 0.22),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            playButtonSfx(context);
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.textSecondary, size: 22),
          ),
        ),
      ),
    );
  }
}
