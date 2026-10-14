import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kare_kapmaca/models/board_size.dart';
import 'package:kare_kapmaca/services/audio_service.dart';
import 'package:kare_kapmaca/services/settings_service.dart';
import 'package:kare_kapmaca/widgets/board_size_selector.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'Custom tile opens a dialog, rejects letters and sub-minimum values, '
    'and applies a valid custom size',
    (tester) async {
      BoardSize selected = const BoardSize(4, 4);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsService()),
            Provider(create: (_) => AudioService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return BoardSizeSelector(
                    selected: selected,
                    onChanged: (v) => setState(() => selected = v),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // English is the default language.
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      expect(find.text('Custom Board Size'), findsOneWidget);

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));

      // Letters are rejected outright by the digits-only input formatter.
      await tester.enterText(fields.at(0), 'ab');
      await tester.pump();
      expect(tester.widget<TextField>(fields.at(0)).controller!.text, '');

      // Below the minimum (2) keeps the confirm button disabled.
      await tester.enterText(fields.at(0), '1');
      await tester.enterText(fields.at(1), '1');
      await tester.pump();
      final applyButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Apply'),
      );
      expect(applyButton.onPressed, isNull);

      // A valid 5x7 custom size enables and applies.
      await tester.enterText(fields.at(0), '5');
      await tester.enterText(fields.at(1), '7');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Apply'));
      await tester.pumpAndSettle();

      expect(selected.dotsWide, 5);
      expect(selected.dotsHigh, 7);
      expect(find.text('5 x 7'), findsOneWidget);
    },
  );
}
