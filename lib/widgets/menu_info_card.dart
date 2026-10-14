import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass_panel.dart';

/// Small secondary home-menu card (e.g. "Nasıl Oynanır?", "İstatistikler").
///
/// A simple bordered flat card for the Classic theme, a frosted glass
/// panel for the premium (Uzay) theme.
class MenuInfoCard extends StatefulWidget {
  const MenuInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<MenuInfoCard> createState() => _MenuInfoCardState();
}

class _MenuInfoCardState extends State<MenuInfoCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          widget.icon,
          color: AppColors.isPremium ? AppColors.glow : AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(height: 10),
        Text(
          widget.title,
          style: AppTheme.body(13, color: AppColors.textPrimary, weight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          widget.subtitle,
          style: AppTheme.body(11, color: AppColors.textSecondary, weight: FontWeight.w500),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {
        playButtonSfx(context);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AppColors.isPremium
            ? GlassPanel(
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: content,
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: content,
              ),
      ),
    );
  }
}
