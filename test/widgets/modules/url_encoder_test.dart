import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/url_encoder.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: UrlEncodeDialog()));

  testWidgets('encodes text for use in a URL', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'a b&c');
    await tester.pump();
    expect(find.text('a%20b%26c'), findsOneWidget);
  });

  testWidgets('decodes an encoded string after switching mode', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Decode'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'a%20b%26c');
    await tester.pump();
    expect(find.text('a b&c'), findsOneWidget);
  });

  testWidgets('invalid percent-encoding shows an error instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Decode'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '%zz');
    await tester.pump();
    expect(
      find.text('Invalid input: not a validly encoded URL string.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'switching mode while showing an error does not crash (regression)',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('Decode'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '%zz');
      await tester.pump();

      await tester.tap(find.text('Encode'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
