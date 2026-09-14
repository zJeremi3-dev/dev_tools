import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/password_generator.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: PasswordGenDialog()));

  testWidgets('length field shows the default length on open', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.text('16'), findsOneWidget);
  });

  testWidgets(
    'tapping generate with default settings does not crash (regression)',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('generated password matches the requested length', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    final pwText = tester.widget<Text>(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.style?.fontFamily == 'monospace' &&
            (w.data?.isNotEmpty ?? false),
      ),
    );
    expect(pwText.data!.length, 16);
  });

  testWidgets('generated password respects a shorter custom length', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.enterText(find.byType(TextField).first, '8');
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    final pwText = tester.widget<Text>(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.style?.fontFamily == 'monospace' &&
            (w.data?.isNotEmpty ?? false),
      ),
    );
    expect(pwText.data!.length, 8);
  });

  testWidgets('unchecking A-Z removes uppercase letters from the result', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byType(Checkbox).at(0)); // A-Z
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    final pwText = tester.widget<Text>(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.style?.fontFamily == 'monospace' &&
            (w.data?.isNotEmpty ?? false),
      ),
    );
    expect(RegExp('[A-Z]').hasMatch(pwText.data!), isFalse);
  });
}
