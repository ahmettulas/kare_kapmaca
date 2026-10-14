import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kare_kapmaca/screens/settings_screen.dart';
import 'package:kare_kapmaca/services/audio_service.dart';
import 'package:kare_kapmaca/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Settings screen shows Sound/Music/Vibration toggles and a working '
    'language switch that relabels the screen live',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsService();
      await settings.load();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            Provider(create: (_) => AudioService()),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // English is the default language.
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Background Music'), findsOneWidget);
      expect(find.text('Vibration'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Turkish'), findsOneWidget);

      final musicSwitch = tester.widget<Switch>(
        find.byType(Switch).at(1),
      );
      expect(musicSwitch.value, isTrue);

      await tester.tap(find.text('Turkish'));
      await tester.pumpAndSettle();

      expect(find.text('AYARLAR'), findsOneWidget);
      expect(find.text('Ses Efektleri'), findsOneWidget);
      expect(find.text('Arka Plan Müziği'), findsOneWidget);
      expect(settings.language.toString(), contains('tr'));
    },
  );
}
