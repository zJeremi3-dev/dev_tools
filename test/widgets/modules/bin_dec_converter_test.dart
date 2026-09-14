import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/bin_dec_converter.dart';

void main() {
  Widget wrap() =>
      const MaterialApp(home: Scaffold(body: BinDecConverterDialog()));

  testWidgets('converts decimal to binary', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '10');
    await tester.pump();
    expect(find.text('Binary: 1010'), findsOneWidget);
  });

  testWidgets('converts binary to decimal after switching mode', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Binary to Decimal'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '1010');
    await tester.pump();
    expect(find.text('Decimal: 10'), findsOneWidget);
  });

  testWidgets('empty input shows no output', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.text('Binary: '), findsOneWidget);
  });

  testWidgets('binary mode only accepts 0 and 1', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Binary to Decimal'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      '10102',
    ); // '2' gets filtered out
    await tester.pump();
    expect(find.text('Decimal: 10'), findsOneWidget);
  });

  testWidgets('switching mode swaps input and output correctly', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();
    expect(find.text('Binary: 101'), findsOneWidget);

    await tester.tap(find.text('Binary to Decimal'));
    await tester.pump();

    // the input field now shows the previous output ("101")...
    expect(find.text('101'), findsOneWidget);
    // ...and the display shows the previous input as the new "output"
    expect(find.text('Decimal: 5'), findsOneWidget);
  });
}
