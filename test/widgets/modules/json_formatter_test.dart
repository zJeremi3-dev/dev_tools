import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/json_formatter.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: JsonFormatDialog()));

  testWidgets('formats compact JSON with indentation', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '{"a":1}');
    await tester.pump();
    expect(find.text('{\n  "a": 1\n}'), findsOneWidget);
  });

  testWidgets('minifies formatted JSON after switching mode', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '{"a": 1}');
    await tester.pump();
    await tester.tap(find.text('Minify'));
    await tester.pump();
    expect(find.text('{"a":1}'), findsOneWidget);
  });

  testWidgets('invalid JSON shows an error instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '{invalid}');
    await tester.pump();
    expect(find.textContaining('Invalid JSON'), findsOneWidget);
  });

  testWidgets(
    'switching mode while showing an error does not crash (regression)',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.enterText(find.byType(TextField), '{invalid}');
      await tester.pump();
      await tester.tap(find.text('Minify'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
