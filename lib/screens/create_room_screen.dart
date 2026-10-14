import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/board_size.dart';
import '../models/player_profile.dart';
import '../services/local_identity_service.dart';
import '../services/room_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/board_size_selector.dart';
import '../widgets/player_setup_card.dart';
import '../widgets/screen_backdrop.dart';
import '../widgets/setup_header.dart';
import 'waiting_room_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  BoardSize _boardSize = const BoardSize(4, 4);
  PlayerProfile _you = PlayerProfile(name: '', color: AppColors.blue);
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    // Carry over whatever photo was picked earlier this session (if any)
    // so the player doesn't have to re-pick it for every room.
    final identity = context.read<LocalIdentityService>();
    _you = _you.copyWith(
      avatarPath: identity.avatarPath,
      avatarBytes: identity.avatarBytes,
    );
  }

  void _onYouChanged(PlayerProfile p) {
    setState(() => _you = p);
    context.read<LocalIdentityService>().setAvatar(
      path: p.avatarPath,
      bytes: p.avatarBytes,
    );
  }

  Future<void> _createRoom() async {
    if (_creating) return;
    final t = context.read<SettingsService>().strings;
    final you = _you.name.trim().isEmpty
        ? _you.copyWith(name: t.defaultYouName)
        : _you;
    setState(() => _creating = true);
    try {
      final code = await context.read<RoomService>().createRoom(
        host: you,
        boardSize: _boardSize,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WaitingRoomScreen(
            roomCode: code,
            boardSize: _boardSize,
            host: you,
          ),
        ),
      );
    } catch (e) {
      debugPrint('CreateRoomScreen: createRoom failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.roomCreateError)));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    return Scaffold(
      body: ScreenBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 6),
                SetupHeader(title: t.createRoomTitle),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    children: [
                      SectionLabel(t.sectionBoardSize),
                      BoardSizeSelector(
                        selected: _boardSize,
                        onChanged: (v) => setState(() => _boardSize = v),
                      ),
                      const SizedBox(height: 26),
                      SectionLabel(t.sectionPlayerSettings),
                      PlayerSetupCard(
                        label: t.player1YouLabel,
                        profile: _you,
                        onChanged: _onYouChanged,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t.player2Label,
                            style: AppTheme.body(
                              13,
                              color: AppColors.textSecondary,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.surfaceRaised,
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              t.opponentWillPickColor,
                              style: AppTheme.body(
                                14,
                                color: AppColors.textMuted,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        t.createRoomInfoNote,
                        textAlign: TextAlign.center,
                        style: AppTheme.body(
                          12,
                          color: AppColors.textMuted,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AppButton(
                    label: t.createRoomButton,
                    color: AppColors.blue,
                    onPressed: _creating ? null : _createRoom,
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
