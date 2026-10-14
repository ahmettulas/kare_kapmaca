import 'package:flutter_test/flutter_test.dart';
import 'package:kare_kapmaca/l10n/app_strings.dart';
import 'package:kare_kapmaca/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to English and music/sound enabled when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService();
    await settings.load();

    expect(settings.language, AppLanguage.en);
    expect(settings.musicEnabled, isTrue);
    expect(settings.soundEnabled, isTrue);
    expect(settings.strings.createRoomTitle, 'CREATE ROOM');
  });

  test('setLanguage persists and a fresh load reflects it', () async {
    SharedPreferences.setMockInitialValues({});
    final first = SettingsService();
    await first.load();
    await first.setLanguage(AppLanguage.tr);
    expect(first.strings.createRoomTitle, 'ODA KUR');

    final second = SettingsService();
    await second.load();
    expect(second.language, AppLanguage.tr);
  });

  test('setMusicEnabled persists across a fresh load', () async {
    SharedPreferences.setMockInitialValues({});
    final first = SettingsService();
    await first.load();
    await first.setMusicEnabled(false);

    final second = SettingsService();
    await second.load();
    expect(second.musicEnabled, isFalse);
  });
}
