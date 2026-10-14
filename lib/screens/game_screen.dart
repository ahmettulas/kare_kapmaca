import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../game_logic/edge.dart';
import '../game_logic/game_engine.dart';
import '../models/board_size.dart';
import '../models/player_profile.dart';
import '../models/room_data.dart';
import '../models/room_move.dart';
import '../services/audio_service.dart';
import '../services/room_service.dart';
import '../services/settings_service.dart';
import '../services/stats_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/board_widget.dart';
import '../widgets/screen_backdrop.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.boardSize,
    required this.players,
    this.roomCode,
    this.myPlayerIndex,
  });

  final BoardSize boardSize;
  final List<PlayerProfile> players;
  final String? roomCode;

  /// Which player this device controls (0 = host, 1 = guest) when
  /// [roomCode] is set. Null for same-device local play, where either
  /// player can tap on their turn.
  final int? myPlayerIndex;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameEngine _engine;
  bool _finished = false;
  StreamSubscription<RoomData?>? _roomSub;
  int _appliedMoveCount = 0;

  bool get _isOnline => widget.roomCode != null;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine(boardSize: widget.boardSize, players: widget.players);
    _engine.addListener(_onEngineChanged);
    if (_isOnline) {
      _roomSub = context
          .read<RoomService>()
          .watchRoom(widget.roomCode!)
          .listen(_onRoomUpdate, onError: _onRoomError);
    }
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _engine.removeListener(_onEngineChanged);
    _engine.dispose();
    super.dispose();
  }

  void _onRoomUpdate(RoomData? room) {
    // The room document is deleted the moment either player leaves (see
    // RoomService.deleteRoom), so on the *other* device this stream fires
    // with `null` — that's the signal the opponent left, unless this
    // device is the one that just deleted it itself (_finished already
    // true from _confirmQuit / the game-over branch below).
    if (room == null) {
      if (!_finished) {
        _finished = true;
        final t = context.read<SettingsService>().strings;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.opponentLeftMessage)));
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }
      return;
    }
    for (var i = _appliedMoveCount; i < room.moves.length; i++) {
      _applyMove(room.moves[i].edge);
    }
    _appliedMoveCount = room.moves.length;
  }

  // Without this, a broken Firestore listen (permission error, network
  // drop) leaves both players stuck on a board that will never update
  // again — indistinguishable from a freeze. Surface it and bail out
  // instead of hanging silently.
  void _onRoomError(Object error) {
    debugPrint('GameScreen: room stream error for ${widget.roomCode}: $error');
    if (_finished) return;
    _finished = true;
    final t = context.read<SettingsService>().strings;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.connectionLostError)));
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  void _applyMove(EdgeId edge) {
    final settings = context.read<SettingsService>();
    final audio = context.read<AudioService>();
    final boxesBefore = _engine.boxesClaimed;
    if (!_engine.claimEdge(edge)) return;
    final boxCompleted = _engine.boxesClaimed > boxesBefore;
    audio.playSfx(
      boxCompleted ? SfxEvent.boxComplete : SfxEvent.placement,
      enabled: settings.soundEnabled,
    );
    if (boxCompleted && settings.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void _submitMove(EdgeId edge) {
    // Online moves are never applied locally — they only take effect once
    // they round-trip through the room stream (see _onRoomUpdate). If the
    // write itself fails, that round-trip never happens and the tap just
    // looks like it did nothing, which reads as an unresponsive/frozen
    // board — so a failure here needs to actually tell the player.
    context
        .read<RoomService>()
        .submitMove(
          widget.roomCode!,
          RoomMove(edge: edge, player: _engine.currentPlayerIndex),
        )
        .catchError((Object error) {
          debugPrint(
            'GameScreen: submitMove failed for ${widget.roomCode}: $error',
          );
          if (!mounted) return;
          final t = context.read<SettingsService>().strings;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.moveSyncError)));
        });
  }

  void _onEngineChanged() {
    if (_engine.isGameOver && !_finished) {
      _finished = true;
      if (_isOnline) context.read<RoomService>().deleteRoom(widget.roomCode!);
      context.read<StatsService>().recordGame(
        player1Name: widget.players[0].name,
        player1Score: _engine.scores[0],
        player2Name: widget.players[1].name,
        player2Score: _engine.scores[1],
        boardLabel: widget.boardSize.label,
        longestStreakThisGame:
            _engine.longestStreak[0] > _engine.longestStreak[1]
            ? _engine.longestStreak[0]
            : _engine.longestStreak[1],
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameOverScreen(
              players: widget.players,
              scores: List.of(_engine.scores),
              longestStreaks: List.of(_engine.longestStreak),
              moveCounts: List.of(_engine.moveCounts),
              boardSize: widget.boardSize,
              roomCode: widget.roomCode,
            ),
          ),
        );
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _confirmQuit() async {
    final t = context.read<SettingsService>().strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          t.quitDialogTitle,
          style: AppTheme.display(18, color: Colors.white),
        ),
        content: Text(
          t.quitDialogBody,
          style: AppTheme.body(14, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              playButtonSfx(context);
              Navigator.of(context).pop(false);
            },
            child: Text(
              t.cancelLabel,
              style: AppTheme.body(14, color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              playButtonSfx(context);
              Navigator.of(context).pop(true);
            },
            child: Text(
              t.quitLabel,
              style: AppTheme.body(
                14,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      if (_isOnline && !_finished) {
        _finished = true;
        context.read<RoomService>().deleteRoom(widget.roomCode!);
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    final p1 = widget.players[0];
    final p2 = widget.players[1];
    final current = widget.players[_engine.currentPlayerIndex];

    return Scaffold(
      body: ScreenBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PlayerBadge(profile: p1, alignRight: false),
                    Column(
                      children: [
                        Text(
                          '${_engine.scores[0]} - ${_engine.scores[1]}',
                          style: AppTheme.display(30, color: Colors.white),
                        ),
                        Text(
                          widget.boardSize.label,
                          style: AppTheme.body(
                            12,
                            color: AppColors.textMuted,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    _PlayerBadge(profile: p2, alignRight: true),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: BoardWidget(
                        engine: _engine,
                        players: widget.players,
                        interactive:
                            widget.myPlayerIndex == null ||
                            _engine.currentPlayerIndex ==
                                widget.myPlayerIndex,
                        onRemoteMove: _isOnline ? _submitMove : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${t.turnPrefix}: ${current.name.toUpperCase()}',
                  style: AppTheme.display(15, color: current.color),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.roomCode == null)
                      _ActionButton(
                        icon: Icons.undo_rounded,
                        label: t.undoLabel,
                        enabled: _engine.canUndo,
                        onTap: _engine.undo,
                      ),
                    _ActionButton(
                      icon: Icons.flag_rounded,
                      label: t.quitGameLabel,
                      enabled: true,
                      onTap: _confirmQuit,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  const _PlayerBadge({required this.profile, required this.alignRight});

  final PlayerProfile profile;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final children = [
      AvatarCircle(
        name: profile.name,
        color: profile.color,
        avatarPath: profile.avatarPath,
        avatarBytes: profile.avatarBytes,
        size: 40,
      ),
      const SizedBox(width: 8),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 78),
        child: Text(
          profile.name,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.body(
            13,
            color: profile.color,
            weight: FontWeight.w800,
          ),
        ),
      ),
    ];
    return Row(children: alignRight ? children.reversed.toList() : children);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.textPrimary : AppColors.textMuted;
    return Column(
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled
                ? () {
                    playButtonSfx(context);
                    onTap();
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: color, size: 22),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTheme.body(11, color: color, weight: FontWeight.w700),
        ),
      ],
    );
  }
}
