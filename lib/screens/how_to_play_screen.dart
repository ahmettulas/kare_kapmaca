import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_backdrop.dart';
import '../widgets/setup_header.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  List<(IconData, String, String)> _steps(AppStrings t) => [
    (Icons.grid_4x4_rounded, t.step1Title, t.step1Body),
    (Icons.crop_square_rounded, t.step2Title, t.step2Body),
    (Icons.replay_circle_filled_rounded, t.step3Title, t.step3Body),
    (Icons.swap_horiz_rounded, t.step4Title, t.step4Body),
    (Icons.emoji_events_rounded, t.step5Title, t.step5Body),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    final steps = _steps(t);
    return Scaffold(
      body: ScreenBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 6),
                SetupHeader(title: t.howToPlayScreenTitle),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: steps.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final (icon, title, body) = steps[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                icon,
                                color: AppColors.blue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. $title',
                                    style: AppTheme.body(
                                      15,
                                      color: AppColors.textPrimary,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    body,
                                    style: AppTheme.body(
                                      13,
                                      color: AppColors.textSecondary,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
