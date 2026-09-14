import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/uuid_generator.dart';

final _uuidV4Pattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: UuidGenDialog()));

  testWidgets('generates 5 UUIDs by default', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.byType(SelectableText), findsNWidgets(5));
  });

  testWidgets('every generated UUID is a valid v4 UUID', (tester) async {
    await tester.pumpWidget(wrap());
    final uuids = tester.widgetList<SelectableText>(
      find.byType(SelectableText),
    );
    for (final t in uuids) {
      expect(
        _uuidV4Pattern.hasMatch(t.data!),
        isTrue,
        reason: 'Invalid UUID: ${t.data}',
      );
    }
  });

  testWidgets('unchecking hyphens removes them from the output', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byType(Checkbox).at(1)); // Hyphens
    await tester.pump();

    final uuid = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .first
        .data!;
    expect(uuid.contains('-'), isFalse);
    expect(uuid.length, 32);
  });

  testWidgets('checking uppercase makes the output uppercase', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byType(Checkbox).at(0)); // Uppercase
    await tester.pump();

    final uuid = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .first
        .data!;
    expect(uuid, uuid.toUpperCase());
  });

  testWidgets('changing the count regenerates that many UUIDs', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), '3');
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();

    expect(find.byType(SelectableText), findsNWidgets(3));
  });
}
