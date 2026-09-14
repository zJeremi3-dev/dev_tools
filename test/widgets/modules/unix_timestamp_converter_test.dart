import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/unix_timestamp_converter.dart';

void main() {
  Widget wrap() =>
      const MaterialApp(home: Scaffold(body: UnixTimestampDialog()));

  testWidgets('epoch (0) converts to the correct UTC date', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    expect(find.text('UTC: 01.01.1970 00:00:00'), findsOneWidget);
  });

  testWidgets('seconds vs. milliseconds toggle changes the interpreted date', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '1000');
    await tester.pump();
    expect(find.text('UTC: 01.01.1970 00:16:40'), findsOneWidget);

    await tester.tap(find.byType(Checkbox)); // Milliseconds
    await tester.pump();
    expect(find.text('UTC: 01.01.1970 00:00:01'), findsOneWidget);
  });

  testWidgets('non-numeric timestamp shows an error instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '-');
    await tester.pump();
    expect(find.text('Invalid timestamp'), findsOneWidget);
  });

  testWidgets(
    'date-to-timestamp mode produces a timestamp for the selected date',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('Date → Timestamp'));
      await tester.pump();

      // default date is DateTime.now(), so we only check that a real
      // timestamp is shown, not a specific value
      expect(find.textContaining('Timestamp: '), findsOneWidget);
      final text = tester
          .widget<Text>(find.textContaining('Timestamp: '))
          .data!;
      expect(text, isNot('Timestamp: —'));
    },
  );
}
