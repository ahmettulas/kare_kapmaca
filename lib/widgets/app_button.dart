import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';

/// Full-width call-to-action button used across setup and result screens
/// (e.g. "ODA OLUŞTUR", "OYUNA BAŞLA", "YENİ OYUN").
///
/// Flat Material button for the Classic theme; premium gradient button
/// (gloss highlight, neon outer glow, tactile press animation) for the
/// premium (Uzay) theme.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
    this.textColor = Colors.white,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color textColor;
  final bool outlined;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (AppColors.isPremium && !widget.outlined && widget.onPressed != null) {
      return _buildPremium();
    }
    return _buildClassic();
  }

  Widget _buildClassic() {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: widget.outlined ? widget.color : widget.textColor, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: AppTheme.display(
            16,
            color: widget.outlined ? widget.color : widget.textColor,
            weight: FontWeight.w700,
          ),
        ),
      ],
    );

    final wrappedOnPressed = widget.onPressed == null
        ? null
        : () {
            playButtonSfx(context);
            widget.onPressed!();
          };

    return SizedBox(
      height: 54,
      child: widget.outlined
          ? OutlinedButton(
              onPressed: wrappedOnPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: widget.color, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: wrappedOnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                disabledBackgroundColor: AppColors.surfaceRaised,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: child,
            ),
    );
  }

  Widget _buildPremium() {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {
        playButtonSfx(context);
        widget.onPressed!();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: AppGradients.forColor(widget.color),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _pressed ? 0.25 : 0.45),
                blurRadius: 22,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.6],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.textColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(widget.label, style: AppTheme.button(16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
