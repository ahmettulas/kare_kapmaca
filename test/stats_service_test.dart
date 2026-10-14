import 'package:flutter_test/flutter_test.dart';
import 'package:kare_kapmaca/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'load() tolerates a pre-custom-board history entry where "size" was '
    'a bare int instead of a "WxH" string, without crashing',
    () async {
      SharedPreferences.setMockInitialValues({
        'games_played': 1,
        'best_streak': 2,
        'total_boxes': 9,
        'game_history': [
          '{"p1n":"Ahmet","p1s":5,"p2n":"Mehmet","p2s":4,'
              '"size":4,"at":"2026-01-01T00:00:00.000"}',
        ],
      });

      final stats = StatsService();
      await stats.load();

      expect(stats.history, hasLength(1));
      expect(stats.history.single.boardLabel, '4x4');
    },
  );

  test('load() skips an unparsable history entry instead of throwing', () async {
    SharedPreferences.setMockInitialValues({
      'game_history': ['not valid json at all'],
    });

    final stats = StatsService();
    await stats.load();

    expect(stats.history, isEmpty);
  });

  test('recordGame() round-trips boardLabel through a fresh load', () async {
    SharedPreferences.setMockInitialValues({});
    final first = StatsService();
    await first.load();
    await first.recordGame(
      player1Name: 'A',
      player1Score: 3,
      player2Name: 'B',
      player2Score: 2,
      boardLabel: '5 x 7',
      longestStreakThisGame: 2,
    );

    final second = StatsService();
    await second.load();
    expect(second.history.single.boardLabel, '5 x 7');
    expect(second.gamesPlayed, 1);
  });
}
