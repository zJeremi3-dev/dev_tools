import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/pw_strength.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: PWStrengthDialog()));

  testWidgets(
    'computes correct entropy and strength label with default charset',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.enterText(
        find.byType(TextField),
        'hello123',
      ); // 8 chars, A-Z+a-z+0-9 pool
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      expect(find.textContaining('47.63'), findsOneWidget);
      expect(find.textContaining('Fair'), findsOneWidget);
    },
  );

  testWidgets('excluding a character set lowers the computed entropy', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byType(Checkbox).at(2)); // uncheck "0-9"
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      'helloabc',
    ); // 8 letters only
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.textContaining('45.60'), findsOneWidget);
    expect(find.textContaining('Fair'), findsOneWidget);
  });

  testWidgets(
    'the password field filters out characters outside the selected sets',
    (tester) async {
      await tester.pumpWidget(wrap());
      // default charset has no symbols enabled, so "!" should be filtered out
      await tester.enterText(find.byType(TextField), 'ab!cd');
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'abcd');
    },
  );

  testWidgets('the test icon switches from play to refresh after first use', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'test1234');
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.byIcon(Icons.play_arrow), findsNothing);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });
}
