import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/settings/module_layout.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('reflects initialValue 1 as Custom checked', (tester) async {
    await tester.pumpWidget(
      wrap(ModuleLayoutSection(initialValue: 1, onChanged: (_) {})),
    );
    final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(boxes[0].value, isTrue); // Custom
    expect(boxes[1].value, isFalse); // Category
    expect(boxes[2].value, isFalse); // Tabular
  });

  testWidgets('reflects initialValue 2 as Category checked', (tester) async {
    await tester.pumpWidget(
      wrap(ModuleLayoutSection(initialValue: 2, onChanged: (_) {})),
    );
    final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(boxes[0].value, isFalse);
    expect(boxes[1].value, isTrue);
    expect(boxes[2].value, isFalse);
  });

  testWidgets('reflects initialValue 3 as Tabular checked', (tester) async {
    await tester.pumpWidget(
      wrap(ModuleLayoutSection(initialValue: 3, onChanged: (_) {})),
    );
    final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(boxes[0].value, isFalse);
    expect(boxes[1].value, isFalse);
    expect(boxes[2].value, isTrue);
  });

  testWidgets('tapping Category calls onChanged with 2', (tester) async {
    int? result;
    await tester.pumpWidget(
      wrap(ModuleLayoutSection(initialValue: 1, onChanged: (t) => result = t)),
    );
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    expect(result, 2);
  });

  testWidgets('tapping Tabular calls onChanged with 3', (tester) async {
    int? result;
    await tester.pumpWidget(
      wrap(ModuleLayoutSection(initialValue: 1, onChanged: (t) => result = t)),
    );
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pump();
    expect(result, 3);
  });

  testWidgets('tapping Custom from Tabular calls onChanged with 1', (
    tester,
  ) async {
    int? result;
    await tester.pumpWidget(
      wrap(ModuleLayoutSection(initialValue: 3, onChanged: (t) => result = t)),
    );
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();
    expect(result, 1);
  });
}
