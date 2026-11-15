// ignore: deprecated_member_use
import 'package:flutter/material.dart' as fm;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/color_picker.dart';

void main() {
  Widget wrap() => MaterialApp(
    localizationsDelegates: [fm.DefaultMaterialLocalizations.delegate],
    home: Scaffold(
      body: fm.Material(
        type: fm.MaterialType.transparency,
        child: const ColorPickerDialog(),
      ),
    ),
  );

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
