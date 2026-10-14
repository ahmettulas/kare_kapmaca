import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Shared back-arrow + centered title header used on secondary screens.
class SetupHeader extends StatelessWidget {
  const SetupHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                title,
                style: AppTheme.display(20, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Section label used above grouped controls (e.g. "ALAN BOYUTU SEÇ").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: AppTheme.body(
          13,
          color: AppColors.textSecondary,
          weight: FontWeight.w800,
        ),
      ),
    );
  }
}
