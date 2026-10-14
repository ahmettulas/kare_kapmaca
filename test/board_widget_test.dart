import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kare_kapmaca/game_logic/edge.dart';
import 'package:kare_kapmaca/game_logic/game_engine.dart';
import 'package:kare_kapmaca/models/board_size.dart';
import 'package:kare_kapmaca/models/player_profile.dart';
import 'package:kare_kapmaca/services/audio_service.dart';
import 'package:kare_kapmaca/services/settings_service.dart';
import 'package:kare_kapmaca/widgets/board_widget.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('tapping near a grid line claims that edge', (tester) async {
    final players = [
      PlayerProfile(name: 'A', color: Colors.blue),
      PlayerProfile(name: 'B', color: Colors.red),
    ];
    final engine = GameEngine(boardSize: const BoardSize(4, 4), players: players);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsService()),
          Provider(create: (_) => AudioService()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 320,
              child: BoardWidget(engine: engine, players: players),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // padding=18, usable=320-36=284, spacing=284/3≈94.67
    // Horizontal edge (row 0, col 0) midpoint ≈ (18+47.3, 18) = (65, 18)
    await tester.tapAt(const Offset(65, 20));
    await tester.pump();

    expect(
      engine.isEdgeClaimed(const EdgeId(EdgeType.horizontal, 0, 0)),
      isTrue,
    );
    expect(engine.currentPlayerIndex, 1); // turn passed, no box completed

    // Vertical edge (row 0, col 0) midpoint ≈ (18, 18+47.3) = (18, 65)
    await tester.tapAt(const Offset(20, 65));
    await tester.pump();

    expect(
      engine.isEdgeClaimed(const EdgeId(EdgeType.vertical, 0, 0)),
      isTrue,
    );
    expect(engine.currentPlayerIndex, 0); // turn passed back
  });
}
