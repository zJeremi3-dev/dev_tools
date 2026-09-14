import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/regex_tester.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: RegexTesterDialog()));

  testWidgets('counts matches for a valid pattern', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField).first, '[0-9]+');
    await tester.enterText(find.byType(TextField).last, 'abc123def456');
    await tester.pump();
    expect(find.text('2 matches'), findsOneWidget);
  });

  testWidgets('invalid regex shows an error instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField).first, '(');
    await tester.pump();
    expect(find.textContaining('Invalid regex'), findsOneWidget);
  });

  testWidgets('ignore case affects matching', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField).first, 'ABC');
    await tester.enterText(find.byType(TextField).last, 'abc');
    await tester.pump();
    expect(find.text('0 matches'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first); // Ignore case
    await tester.pump();
    expect(find.text('1 matches'), findsOneWidget);
  });
}
