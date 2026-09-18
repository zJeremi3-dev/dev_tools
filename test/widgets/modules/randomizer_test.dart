import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/randomizer.dart';

void main() {
  Widget wrap() =>
      const MaterialApp(home: Scaffold(body: RandomNumberDialog()));

  int? extractResult(WidgetTester tester) {
    final text = tester.widget<Text>(find.textContaining('Result: ')).data!;
    final match = RegExp(r'Result: (-?\d+)').firstMatch(text);
    return match == null ? null : int.parse(match.group(1)!);
  }

  testWidgets('generates a number within the default 1-100 range on open', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    final result = extractResult(tester);
    expect(result, isNotNull);
    expect(result! >= 1 && result <= 100, isTrue);
  });

  testWidgets('a range of a single number always returns that number', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '5');
    await tester.enterText(fields.last, '5');
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();

    expect(extractResult(tester), 5);
  });

  testWidgets('an inverted range (From > To) is swapped and stays in bounds', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '50');
    await tester.enterText(fields.last, '10');
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();

    // fields should now show the swapped values
    expect(find.text('10'), findsOneWidget); // From
    expect(find.text('50'), findsOneWidget); // To

    final result = extractResult(tester);
    expect(result! >= 10 && result <= 50, isTrue);
  });

  testWidgets('repeated generation always stays within the given range', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '1');
    await tester.enterText(fields.last, '3');
    await tester.pump();

    for (var i = 0; i < 20; i++) {
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();
      final result = extractResult(tester);
      expect(result! >= 1 && result <= 3, isTrue);
    }
  });

  testWidgets(
    'dialog title says "Randomizer" (regression for copy-paste bug)',
    (tester) async {
      await tester.pumpWidget(wrap());
      expect(find.text('Randomizer'), findsOneWidget);
    },
  );
}
