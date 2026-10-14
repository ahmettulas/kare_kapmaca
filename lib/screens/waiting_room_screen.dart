import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/board_size.dart';
import '../models/player_profile.dart';
import '../models/room_data.dart';
import '../services/room_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/screen_backdrop.dart';
import '../widgets/setup_header.dart';
import 'game_screen.dart';

/// Shown to the host right after creating a room: displays the code and
/// waits (via a live Firestore stream) for a guest to join, then
/// navigates both players into the synced [GameScreen].
class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({
    super.key,
    required this.roomCode,
    required this.boardSize,
    required this.host,
  });

  final String roomCode;
  final BoardSize boardSize;
  final PlayerProfile host;

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  bool _navigated = false;

  Future<void> _cancel() async {
    try {
      await context.read<RoomService>().deleteRoom(widget.roomCode);
    } catch (e) {
      // Best-effort cleanup — a failed remote delete (network drop, etc.)
      // shouldn't trap the player on this screen with a button that
      // looks like it does nothing; a stale room doc is the lesser evil.
      debugPrint('WaitingRoomScreen: deleteRoom(${widget.roomCode}) failed: $e');
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _maybeNavigate(RoomData? room) {
    if (_navigated || room?.guest == null) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameScreen(
            boardSize: widget.boardSize,
            players: [widget.host, room!.guest!],
            roomCode: widget.roomCode,
            myPlayerIndex: 0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    return Scaffold(
      body: ScreenBackdrop(
        child: SafeArea(
          child: StreamBuilder<RoomData?>(
            stream: context.read<RoomService>().watchRoom(widget.roomCode),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Otherwise this screen just spins forever with no way for
                // the player to tell a broken listen apart from an
                // opponent who simply hasn't joined yet.
                debugPrint(
                  'WaitingRoomScreen: room stream error for '
                  '${widget.roomCode}: ${snapshot.error}',
                );
              }
              _maybeNavigate(snapshot.data);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    SetupHeader(title: t.waitingRoomTitle),
                    const Spacer(),
                    Text(
                      t.waitingForOpponentBody,
                      textAlign: TextAlign.center,
                      style: AppTheme.body(
                        14,
                        color: AppColors.textSecondary,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (snapshot.hasError) ...[
                      Text(
                        t.connectionLostError,
                        textAlign: TextAlign.center,
                        style: AppTheme.body(
                          13,
                          color: AppColors.red,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    GestureDetector(
                      onTap: () => Clipboard.setData(
                        ClipboardData(text: widget.roomCode),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.roomCode,
                              style: AppTheme.display(34, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.copy_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!snapshot.hasError)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    const Spacer(),
                    AppButton(
                      label: t.cancelLabel,
                      color: AppColors.surfaceRaised,
                      onPressed: _cancel,
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
