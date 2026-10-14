import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameResult {
  GameResult({
    required this.player1Name,
    required this.player1Score,
    required this.player2Name,
    required this.player2Score,
    required this.boardLabel,
    required this.playedAt,
  });

  final String player1Name;
  final int player1Score;
  final String player2Name;
  final int player2Score;
  final String boardLabel;
  final DateTime playedAt;

  Map<String, dynamic> toJson() => {
    'p1n': player1Name,
    'p1s': player1Score,
    'p2n': player2Name,
    'p2s': player2Score,
    'size': boardLabel,
    'at': playedAt.toIso8601String(),
  };

  factory GameResult.fromJson(Map<String, dynamic> json) {
    // 'size' used to be a single int (dotsPerSide, always square) before
    // custom rectangular boards existed — reconstruct a label for it.
    final rawSize = json['size'];
    final boardLabel = rawSize is String ? rawSize : '${rawSize}x$rawSize';
    return GameResult(
      player1Name: json['p1n'] as String,
      player1Score: json['p1s'] as int,
      player2Name: json['p2n'] as String,
      player2Score: json['p2s'] as int,
      boardLabel: boardLabel,
      playedAt: DateTime.parse(json['at'] as String),
    );
  }
}

/// Persists lightweight local play statistics across sessions using
/// [SharedPreferences]. No account/backend involved.
class StatsService extends ChangeNotifier {
  static const _historyKey = 'game_history';
  static const _gamesPlayedKey = 'games_played';
  static const _bestStreakKey = 'best_streak';
  static const _totalBoxesKey = 'total_boxes';
  static const _maxHistory = 20;

  SharedPreferences? _prefs;

  int gamesPlayed = 0;
  int bestStreak = 0;
  int totalBoxes = 0;
  List<GameResult> history = [];

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final prefs = _prefs!;
    gamesPlayed = prefs.getInt(_gamesPlayedKey) ?? 0;
    bestStreak = prefs.getInt(_bestStreakKey) ?? 0;
    totalBoxes = prefs.getInt(_totalBoxesKey) ?? 0;
    final raw = prefs.getStringList(_historyKey) ?? [];
    history = [];
    for (final entry in raw) {
      try {
        history.add(
          GameResult.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } catch (e) {
        // Skip a corrupted/incompatible entry rather than failing to load.
        debugPrint('StatsService: skipping unparsable history entry: $e');
      }
    }
    notifyListeners();
  }

  Future<void> recordGame({
    required String player1Name,
    required int player1Score,
    required String player2Name,
    required int player2Score,
    required String boardLabel,
    required int longestStreakThisGame,
  }) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();

    gamesPlayed += 1;
    totalBoxes += player1Score + player2Score;
    if (longestStreakThisGame > bestStreak) bestStreak = longestStreakThisGame;

    history.insert(
      0,
      GameResult(
        player1Name: player1Name,
        player1Score: player1Score,
        player2Name: player2Name,
        player2Score: player2Score,
        boardLabel: boardLabel,
        playedAt: DateTime.now(),
      ),
    );
    if (history.length > _maxHistory) {
      history = history.sublist(0, _maxHistory);
    }

    await prefs.setInt(_gamesPlayedKey, gamesPlayed);
    await prefs.setInt(_bestStreakKey, bestStreak);
    await prefs.setInt(_totalBoxesKey, totalBoxes);
    await prefs.setStringList(
      _historyKey,
      history.map((e) => jsonEncode(e.toJson())).toList(),
    );

    notifyListeners();
  }
}
