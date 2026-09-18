import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/barcode_generator.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: BarcodeGenDialog()));

  Future<void> selectType(WidgetTester tester, String type) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(type).last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows a placeholder before any text is entered', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.text('Enter Text …'), findsOneWidget);
  });

  testWidgets('Code128 (default type) accepts arbitrary text', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'Hello World 123');
    await tester.pump();
    expect(find.textContaining('Invalid for'), findsNothing);
  });

  testWidgets('EAN-13 rejects an invalid checksum', (tester) async {
    await tester.pumpWidget(wrap());
    await selectType(tester, 'EAN-13');
    await tester.enterText(find.byType(TextField), '1234567890123');
    await tester.pump();
    expect(find.textContaining('Invalid for EAN-13'), findsOneWidget);
  });

  testWidgets('EAN-13 accepts a valid checksum', (tester) async {
    await tester.pumpWidget(wrap());
    await selectType(tester, 'EAN-13');
    await tester.enterText(find.byType(TextField), '4006381333931');
    await tester.pump();
    expect(find.textContaining('Invalid for'), findsNothing);
  });

  testWidgets('switching type re-validates the current text', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '4006381333931');
    await tester.pump();
    expect(
      find.textContaining('Invalid for'),
      findsNothing,
    ); // valid for Code128

    await selectType(tester, 'EAN-8'); // 13 digits is invalid for EAN-8
    expect(find.textContaining('Invalid for EAN-8'), findsOneWidget);
  });
}
