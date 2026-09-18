import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/color_picker.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: ColorPickerDialog()));

  testWidgets('shows the initial accent color as a hex code', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.text('#7C3AED'), findsOneWidget);
  });

  testWidgets('copy button shows a confirmation snackbar', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    expect(find.text('Successfully Copied'), findsOneWidget);
  });
}
