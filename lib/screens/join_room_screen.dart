import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/player_profile.dart';
import '../services/local_identity_service.dart';
import '../services/room_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/player_setup_card.dart';
import '../widgets/screen_backdrop.dart';
import '../widgets/setup_header.dart';
import 'game_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _controller = TextEditingController();
  PlayerProfile _you = PlayerProfile(name: '', color: AppColors.red);
  bool _joining = false;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (_joining) return;
    final t = context.read<SettingsService>().strings;
    final code = _controller.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.invalidRoomIdError)));
      return;
    }
    final you = _you.name.trim().isEmpty
        ? _you.copyWith(name: t.defaultYouName)
        : _you;
    setState(() => _joining = true);
    try {
      final room = await context.read<RoomService>().joinRoom(
        code: code,
        guest: you,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameScreen(
            boardSize: room.boardSize,
            players: [room.host, you],
            roomCode: code,
            myPlayerIndex: 1,
          ),
        ),
      );
    } on RoomNotFoundException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.roomNotFoundError)));
    } on RoomFullException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.roomFullError)));
    } catch (e) {
      // Anything else (network drop, Firestore rejection, etc.) — without
      // this, the join silently no-ops and the button just re-enables
      // with zero feedback, which reads as a freeze.
      debugPrint('JoinRoomScreen: joinRoom failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.roomJoinError)));
    } finally {
      if (mounted) setState(() => _joining = false);
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
                SetupHeader(title: t.joinRoomTitle),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.green,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.people_alt_rounded,
                              color: AppColors.green,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            t.joinRoomIntro,
                            textAlign: TextAlign.center,
                            style: AppTheme.body(
                              14,
                              color: AppColors.textSecondary,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              t.roomIdLabel,
                              style: AppTheme.body(
                                12,
                                color: AppColors.textMuted,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              textAlign: TextAlign.center,
                              style: AppTheme.display(20, color: Colors.white),
                              decoration: InputDecoration(
                                hintText: t.roomIdHint,
                                hintStyle: AppTheme.display(
                                  20,
                                  color: AppColors.textMuted,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.content_paste_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () async {
                                    final data = await Clipboard.getData(
                                      'text/plain',
                                    );
                                    if (data?.text != null) {
                                      final digits = data!.text!
                                          .trim()
                                          .replaceAll(RegExp(r'[^0-9]'), '');
                                      _controller.text = digits.length > 6
                                          ? digits.substring(0, 6)
                                          : digits;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          PlayerSetupCard(
                            label: t.player1YouLabel,
                            profile: _you,
                            onChanged: _onYouChanged,
                          ),
                          const SizedBox(height: 26),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.help_outline_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.howToFindTitle,
                                        style: AppTheme.body(
                                          12,
                                          color: AppColors.textPrimary,
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t.howToFindBody,
                                        style: AppTheme.body(
                                          12,
                                          color: AppColors.textSecondary,
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AppButton(
                    label: t.joinButton,
                    color: AppColors.green,
                    onPressed: _joining ? null : _join,
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
