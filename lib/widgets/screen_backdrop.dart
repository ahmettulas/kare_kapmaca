import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Wraps a screen body so the shared space backdrop (photo or
/// procedural scene, painted behind everything by MaterialApp.builder)
/// shows through blurred — keeps text legible on every screen except
/// the Main Menu, which shows it sharp. No-op for the Classic theme
/// (which has no shared backdrop to blur).
class ScreenBackdrop extends StatelessWidget {
  const ScreenBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppColors.isPremium) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: const SizedBox.expand(),
        ),
        child,
      ],
    );
  }
}
