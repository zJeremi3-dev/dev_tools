import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/qr_generator.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: QRGenDialog()));

  testWidgets('shows a placeholder before any text is entered', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.text('Enter text …'), findsOneWidget);
  });

  testWidgets('generates a QR code for normal text without error', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'https://example.com');
    await tester.pump();
    expect(find.text('Enter text …'), findsNothing);
    expect(find.textContaining('too long'), findsNothing);
  });

  testWidgets('shows an error for text too long to encode', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'a'.padRight(5000, 'a'));
    await tester.pump();
    expect(find.textContaining('too long'), findsOneWidget);
  });

  testWidgets(
    'clearing the text removes the error and shows the placeholder again',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.enterText(find.byType(TextField), 'a'.padRight(5000, 'a'));
      await tester.pump();
      expect(find.textContaining('too long'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('Enter text …'), findsOneWidget);
    },
  );
}
