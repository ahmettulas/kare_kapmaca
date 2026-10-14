import 'package:flutter_test/flutter_test.dart';

import 'package:kare_kapmaca/main.dart';

void main() {
  testWidgets('Main menu shows the game title and mode buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KareKapmacaApp());
    await tester.pumpAndSettle();

    // English is the default language.
    expect(find.text('DOTS'), findsOneWidget);
    expect(find.text('BOXES'), findsOneWidget);
    expect(find.text('CREATE ROOM'), findsOneWidget);
    expect(find.text('JOIN ROOM'), findsOneWidget);
    expect(find.text('SAME PHONE'), findsOneWidget);
  });
}
