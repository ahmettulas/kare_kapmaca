import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/board_size.dart';
import '../models/player_profile.dart';
import '../services/ad_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/screen_backdrop.dart';
import 'game_screen.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.players,
    required this.scores,
    required this.longestStreaks,
    required this.moveCounts,
    required this.boardSize,
    this.roomCode,
  });

  final List<PlayerProfile> players;
  final List<int> scores;
  final List<int> longestStreaks;
  final List<int> moveCounts;
  final BoardSize boardSize;
  final String? roomCode;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2))
      ..play();
    context.read<AdService>().showAfterGame();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    final isDraw = widget.scores[0] == widget.scores[1];
    final winnerIndex = isDraw
        ? -1
        : (widget.scores[0] > widget.scores[1] ? 0 : 1);

    return Scaffold(
      body: ScreenBackdrop(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      t.gameOverTitle,
                      style: AppTheme.display(26, color: AppColors.green),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ResultBadge(
                          profile: widget.players[0],
                          score: widget.scores[0],
                          isWinner: winnerIndex == 0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            t.vsLabel,
                            style: AppTheme.display(
                              18,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        _ResultBadge(
                          profile: widget.players[1],
                          score: widget.scores[1],
                          isWinner: winnerIndex == 1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _StatRow(
                            label: t.statBoxesCreated,
                            left: widget.scores[0],
                            right: widget.scores[1],
                          ),
                          Divider(color: AppColors.border, height: 22),
                          _StatRow(
                            label: t.statLongestStreak,
                            left: widget.longestStreaks[0],
                            right: widget.longestStreaks[1],
                          ),
                          Divider(color: AppColors.border, height: 22),
                          _StatRow(
                            label: t.statMoveCount,
                            left: widget.moveCounts[0],
                            right: widget.moveCounts[1],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    AppButton(
                      label: t.newGameButton,
                      color: AppColors.blue,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    if (widget.roomCode == null) ...[
                      const SizedBox(height: 12),
                      AppButton(
                        label: t.rematchButton,
                        color: AppColors.green,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => GameScreen(
                                boardSize: widget.boardSize,
                                players: widget.players,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    AppButton(
                      label: t.mainMenuButton,
                      color: AppColors.surfaceRaised,
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                    ),
                    const SizedBox(height: 16),
                    if (widget.roomCode != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${t.roomIdPrefix}: ${widget.roomCode}',
                            style: AppTheme.body(
                              12,
                              color: AppColors.textMuted,
                              weight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () => Clipboard.setData(
                              ClipboardData(text: widget.roomCode!),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirection: pi / 2,
                    maxBlastForce: 12,
                    minBlastForce: 6,
                    numberOfParticles: 24,
                    gravity: 0.25,
                    shouldLoop: false,
                    colors: [
                      AppColors.gold,
                      AppColors.blue,
                      AppColors.green,
                      AppColors.red,
                      AppColors.purple,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({
    required this.profile,
    required this.score,
    required this.isWinner,
  });

  final PlayerProfile profile;
  final int score;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AvatarCircle(
              name: profile.name,
              color: profile.color,
              avatarPath: profile.avatarPath,
              avatarBytes: profile.avatarBytes,
              size: 84,
              borderColor: isWinner ? AppColors.gold : null,
            ),
            if (isWinner)
              Positioned(
                top: -18,
                child: Icon(
                  Icons.emoji_events,
                  color: AppColors.gold,
                  size: 26,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          profile.name,
          style: AppTheme.body(
            15,
            color: profile.color,
            weight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text('$score', style: AppTheme.display(28, color: Colors.white)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.left,
    required this.right,
  });

  final String label;
  final int left;
  final int right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            '$left',
            textAlign: TextAlign.center,
            style: AppTheme.body(
              15,
              color: Colors.white,
              weight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.body(
              13,
              color: AppColors.textSecondary,
              weight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$right',
            textAlign: TextAlign.center,
            style: AppTheme.body(
              15,
              color: Colors.white,
              weight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
