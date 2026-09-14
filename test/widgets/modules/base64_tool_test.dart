import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/base64_tool.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: Base64Dialog()));

  testWidgets('encodes plain text to Base64', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    expect(find.text('SGVsbG8='), findsOneWidget);
  });

  testWidgets('decodes Base64 back to plain text after switching mode', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Decode'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'SGVsbG8=');
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('invalid Base64 shows an error instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Decode'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'not valid base64!!!');
    await tester.pump();
    expect(find.text('Invalid input: not valid Base64.'), findsOneWidget);
  });

  testWidgets(
    'switching mode while showing an error does not crash (regression)',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('Decode'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'not valid base64!!!');
      await tester.pump();

      await tester.tap(find.text('Encode'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
