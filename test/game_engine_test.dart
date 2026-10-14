import 'package:flutter_test/flutter_test.dart';
import 'package:kare_kapmaca/game_logic/edge.dart';
import 'package:kare_kapmaca/game_logic/game_engine.dart';
import 'package:kare_kapmaca/models/board_size.dart';
import 'package:kare_kapmaca/models/player_profile.dart';
import 'package:flutter/material.dart';

GameEngine _newEngine({int dotsPerSide = 3}) {
  return GameEngine(
    boardSize: BoardSize(dotsPerSide, dotsPerSide),
    players: [
      PlayerProfile(name: 'A', color: Colors.blue),
      PlayerProfile(name: 'B', color: Colors.red),
    ],
  );
}

void main() {
  test('claiming a non-completing edge passes the turn', () {
    final engine = _newEngine();
    expect(engine.currentPlayerIndex, 0);
    engine.claimEdge(const EdgeId(EdgeType.horizontal, 0, 0));
    expect(engine.currentPlayerIndex, 1);
    expect(engine.scores, [0, 0]);
  });

  test('completing a box grants an extra turn and a point', () {
    // 2x2 dot grid = a single box, bounded by 4 edges.
    final engine = _newEngine(dotsPerSide: 2);
    engine.claimEdge(const EdgeId(EdgeType.horizontal, 0, 0)); // top -> P1->P2
    expect(engine.currentPlayerIndex, 1);
    engine.claimEdge(const EdgeId(EdgeType.horizontal, 1, 0)); // bottom -> P2->P1... wait P2 made it
    // After 2 non-completing edges, turn should be back with player 0.
    expect(engine.currentPlayerIndex, 0);
    engine.claimEdge(const EdgeId(EdgeType.vertical, 0, 0)); // left -> P1->P2
    expect(engine.currentPlayerIndex, 1);
    // Last edge completes the box for player 1 (current player), who then goes again.
    engine.claimEdge(const EdgeId(EdgeType.vertical, 0, 1)); // right, completes box
    expect(engine.scores[1], 1);
    expect(engine.currentPlayerIndex, 1); // same player continues
    expect(engine.isGameOver, isTrue);
    expect(engine.winnerIndex, 1);
  });

  test('undo reverts edge claim, score and turn', () {
    final engine = _newEngine(dotsPerSide: 2);
    engine.claimEdge(const EdgeId(EdgeType.horizontal, 0, 0));
    engine.claimEdge(const EdgeId(EdgeType.horizontal, 1, 0));
    engine.claimEdge(const EdgeId(EdgeType.vertical, 0, 0));
    engine.claimEdge(const EdgeId(EdgeType.vertical, 0, 1)); // completes box, P1 scores
    expect(engine.scores[1], 1);

    engine.undo();
    expect(engine.scores[1], 0);
    expect(engine.isGameOver, isFalse);
    expect(
      engine.isEdgeClaimed(const EdgeId(EdgeType.vertical, 0, 1)),
      isFalse,
    );
    expect(engine.currentPlayerIndex, 1);
  });

  test('a full 3x3-dot game (4 boxes) ends with all boxes claimed', () {
    final engine = _newEngine(dotsPerSide: 3);
    final allEdges = <EdgeId>[
      for (var r = 0; r < 3; r++)
        for (var c = 0; c < 2; c++) EdgeId(EdgeType.horizontal, r, c),
      for (var r = 0; r < 2; r++)
        for (var c = 0; c < 3; c++) EdgeId(EdgeType.vertical, r, c),
    ];
    for (final edge in allEdges) {
      final applied = engine.claimEdge(edge);
      expect(applied, isTrue);
    }
    expect(engine.isGameOver, isTrue);
    expect(engine.totalBoxes, 4);
    expect(engine.scores[0] + engine.scores[1], 4);
  });
}
