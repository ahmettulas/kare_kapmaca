import 'package:flutter/foundation.dart';

import '../models/board_size.dart';
import '../models/player_profile.dart';
import 'edge.dart';

class _MoveRecord {
  _MoveRecord({
    required this.edge,
    required this.player,
    required this.completedBoxes,
    required this.prevCurrentPlayerIndex,
    required this.prevStreakForPlayer,
  });

  final EdgeId edge;
  final int player;
  final List<(int, int)> completedBoxes;
  final int prevCurrentPlayerIndex;
  final int prevStreakForPlayer;
}

/// Core Dots and Boxes rules engine for exactly two players.
///
/// A grid of [boardSize] dots (possibly rectangular) yields
/// boxesWide x boxesHigh boxes. Claiming an edge that completes one or
/// two boxes grants the same player another turn; otherwise the turn
/// passes to the opponent.
class GameEngine extends ChangeNotifier {
  GameEngine({required this.boardSize, required this.players})
    : assert(players.length == 2) {
    final dotsWide = boardSize.dotsWide;
    final dotsHigh = boardSize.dotsHigh;
    _horizontalClaimed = List.generate(
      dotsHigh,
      (_) => List.filled(dotsWide - 1, false),
    );
    _horizontalOwner = List.generate(
      dotsHigh,
      (_) => List.filled(dotsWide - 1, -1),
    );
    _verticalClaimed = List.generate(
      dotsHigh - 1,
      (_) => List.filled(dotsWide, false),
    );
    _verticalOwner = List.generate(
      dotsHigh - 1,
      (_) => List.filled(dotsWide, -1),
    );
    _boxOwner = List.generate(
      boxesHigh,
      (_) => List.filled(boxesWide, -1),
    );
  }

  final BoardSize boardSize;
  final List<PlayerProfile> players;

  int get dotsWide => boardSize.dotsWide;
  int get dotsHigh => boardSize.dotsHigh;
  int get boxesWide => boardSize.boxesWide;
  int get boxesHigh => boardSize.boxesHigh;
  int get totalBoxes => boxesWide * boxesHigh;

  late List<List<bool>> _horizontalClaimed;
  late List<List<int>> _horizontalOwner;
  late List<List<bool>> _verticalClaimed;
  late List<List<int>> _verticalOwner;
  late List<List<int>> _boxOwner;

  final List<int> scores = [0, 0];
  final List<int> moveCounts = [0, 0];
  final List<int> currentStreak = [0, 0];
  final List<int> longestStreak = [0, 0];

  int currentPlayerIndex = 0;
  final List<_MoveRecord> _history = [];

  bool get isGameOver =>
      scores[0] + scores[1] == totalBoxes && totalBoxes > 0;

  int get boxesClaimed => scores[0] + scores[1];

  /// Index of the leading player, or -1 on a tie.
  int get winnerIndex {
    if (scores[0] == scores[1]) return -1;
    return scores[0] > scores[1] ? 0 : 1;
  }

  bool get canUndo => _history.isNotEmpty;

  bool isEdgeClaimed(EdgeId id) => switch (id.type) {
    EdgeType.horizontal => _horizontalClaimed[id.row][id.col],
    EdgeType.vertical => _verticalClaimed[id.row][id.col],
  };

  int edgeOwner(EdgeId id) => switch (id.type) {
    EdgeType.horizontal => _horizontalOwner[id.row][id.col],
    EdgeType.vertical => _verticalOwner[id.row][id.col],
  };

  int boxOwnerAt(int row, int col) => _boxOwner[row][col];

  bool _isValidEdge(EdgeId id) {
    if (id.type == EdgeType.horizontal) {
      return id.row >= 0 &&
          id.row < dotsHigh &&
          id.col >= 0 &&
          id.col < dotsWide - 1;
    }
    return id.row >= 0 &&
        id.row < dotsHigh - 1 &&
        id.col >= 0 &&
        id.col < dotsWide;
  }

  bool _isBoxComplete(int row, int col) {
    return _horizontalClaimed[row][col] &&
        _horizontalClaimed[row + 1][col] &&
        _verticalClaimed[row][col] &&
        _verticalClaimed[row][col + 1];
  }

  /// Attempts to claim [id] for the current player. Returns true if the
  /// move was applied (edge was valid and unclaimed).
  bool claimEdge(EdgeId id) {
    if (isGameOver || !_isValidEdge(id) || isEdgeClaimed(id)) return false;

    final player = currentPlayerIndex;
    if (id.type == EdgeType.horizontal) {
      _horizontalClaimed[id.row][id.col] = true;
      _horizontalOwner[id.row][id.col] = player;
    } else {
      _verticalClaimed[id.row][id.col] = true;
      _verticalOwner[id.row][id.col] = player;
    }
    moveCounts[player]++;

    final completed = <(int, int)>[];
    for (final (boxRow, boxCol) in _adjacentBoxes(id)) {
      if (_boxOwner[boxRow][boxCol] == -1 && _isBoxComplete(boxRow, boxCol)) {
        _boxOwner[boxRow][boxCol] = player;
        scores[player]++;
        completed.add((boxRow, boxCol));
      }
    }

    final prevCurrentPlayerIndex = currentPlayerIndex;
    final prevStreak = currentStreak[player];

    if (completed.isNotEmpty) {
      currentStreak[player] += completed.length;
      if (currentStreak[player] > longestStreak[player]) {
        longestStreak[player] = currentStreak[player];
      }
    } else {
      currentStreak[player] = 0;
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }

    _history.add(
      _MoveRecord(
        edge: id,
        player: player,
        completedBoxes: completed,
        prevCurrentPlayerIndex: prevCurrentPlayerIndex,
        prevStreakForPlayer: prevStreak,
      ),
    );

    notifyListeners();
    return true;
  }

  /// Reverts the most recent move, if any.
  void undo() {
    if (_history.isEmpty) return;
    final last = _history.removeLast();

    if (last.edge.type == EdgeType.horizontal) {
      _horizontalClaimed[last.edge.row][last.edge.col] = false;
      _horizontalOwner[last.edge.row][last.edge.col] = -1;
    } else {
      _verticalClaimed[last.edge.row][last.edge.col] = false;
      _verticalOwner[last.edge.row][last.edge.col] = -1;
    }
    moveCounts[last.player]--;

    for (final (boxRow, boxCol) in last.completedBoxes) {
      _boxOwner[boxRow][boxCol] = -1;
      scores[last.player]--;
    }

    currentStreak[last.player] = last.prevStreakForPlayer;
    currentPlayerIndex = last.prevCurrentPlayerIndex;

    notifyListeners();
  }

  List<(int, int)> _adjacentBoxes(EdgeId id) {
    final boxes = <(int, int)>[];
    if (id.type == EdgeType.horizontal) {
      if (id.row - 1 >= 0) boxes.add((id.row - 1, id.col));
      if (id.row < boxesHigh) boxes.add((id.row, id.col));
    } else {
      if (id.col - 1 >= 0) boxes.add((id.row, id.col - 1));
      if (id.col < boxesWide) boxes.add((id.row, id.col));
    }
    return boxes;
  }
}
