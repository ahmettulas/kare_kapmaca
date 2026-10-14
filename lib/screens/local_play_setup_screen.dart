import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/board_size.dart';
import '../models/player_profile.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/board_size_selector.dart';
import '../widgets/player_setup_card.dart';
import '../widgets/screen_backdrop.dart';
import '../widgets/setup_header.dart';
import 'game_screen.dart';

class LocalPlaySetupScreen extends StatefulWidget {
  const LocalPlaySetupScreen({super.key});

  @override
  State<LocalPlaySetupScreen> createState() => _LocalPlaySetupScreenState();
}

class _LocalPlaySetupScreenState extends State<LocalPlaySetupScreen> {
  BoardSize _boardSize = const BoardSize(4, 4);
  PlayerProfile _p1 = PlayerProfile(name: 'Ahmet', color: AppColors.blue);
  PlayerProfile _p2 = PlayerProfile(name: 'Mehmet', color: AppColors.red);

  void _start() {
    final t = context.read<SettingsService>().strings;
    final p1 = _p1.name.trim().isEmpty
        ? _p1.copyWith(name: t.player1Fallback)
        : _p1;
    final p2 = _p2.name.trim().isEmpty
        ? _p2.copyWith(name: t.player2Fallback)
        : _p2;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(boardSize: _boardSize, players: [p1, p2]),
      ),
    );
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
                SetupHeader(title: t.samePhoneScreenTitle),
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
                        label: t.player1Label,
                        profile: _p1,
                        disabledColors: [_p2.color],
                        onChanged: (p) => setState(() => _p1 = p),
                      ),
                      const SizedBox(height: 18),
                      PlayerSetupCard(
                        label: t.player2Label,
                        profile: _p2,
                        disabledColors: [_p1.color],
                        onChanged: (p) => setState(() => _p2 = p),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AppButton(
                    label: t.startGameButton,
                    color: AppColors.orange,
                    onPressed: _start,
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
