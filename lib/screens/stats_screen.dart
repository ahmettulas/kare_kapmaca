import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../services/stats_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_backdrop.dart';
import '../widgets/setup_header.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsService>();
    final t = context.watch<SettingsService>().strings;

    return Scaffold(
      body: ScreenBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 6),
                SetupHeader(title: t.statsScreenTitle),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.sports_esports_rounded,
                              color: AppColors.blue,
                              label: t.gamesPlayedLabel,
                              value: '${stats.gamesPlayed}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.crop_square_rounded,
                              color: AppColors.green,
                              label: t.totalBoxesLabel,
                              value: '${stats.totalBoxes}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.orange,
                        label: t.bestStreakLabel,
                        value: '${stats.bestStreak}',
                        wide: true,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.historyLabel,
                        style: AppTheme.body(
                          13,
                          color: AppColors.textSecondary,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (stats.history.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text(
                              t.noHistoryYet,
                              style: AppTheme.body(
                                13,
                                color: AppColors.textMuted,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        ...stats.history.map(
                          (result) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${result.player1Name} ${result.player1Score} - '
                                    '${result.player2Score} ${result.player2Name}',
                                    style: AppTheme.body(
                                      13,
                                      color: AppColors.textPrimary,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  result.boardLabel,
                                  style: AppTheme.body(
                                    12,
                                    color: AppColors.textMuted,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.wide = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTheme.display(20, color: Colors.white)),
                Text(
                  label,
                  style: AppTheme.body(
                    11,
                    color: AppColors.textSecondary,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
