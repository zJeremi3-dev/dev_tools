import 'package:dev_tools/colors.dart';
import 'package:dev_tools/settings/color_scheme/color_picker_overlay.dart';
import 'package:dev_tools/settings/color_scheme/scheme_adder.dart';
import 'package:dev_tools/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    applyColorScheme(1);
    container = ProviderContainer();
  });

  tearDown(() {
    ColorPickerOverlay.hide();
    container.dispose();
  });

  Future<void> pump(WidgetTester tester) async {
    useLargeSurface(tester);
    await tester.pumpWidget(
      appWith(
        container,
        const SingleChildScrollView(child: SchemeAdderSection()),
      ),
    );
  }

  Future<void> expand(WidgetTester tester) async {
    await tester.tap(find.text('Scheme Adder'));
    await tester.pumpAndSettle();
  }

  // Index 0 = Name, 1..6 = Hex fields (BackGround ... Text Secondary)
  Finder nameField() => find.byType(TextField).first;
  Finder hexField(int i) => find.byType(TextField).at(i + 1);
  String textOf(WidgetTester t, Finder f) =>
      t.widget<TextField>(f).controller!.text;

  Finder swatch() => find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.constraints == BoxConstraints.tightFor(width: 30, height: 30),
  );

  List<dynamic> ownSchemes() =>
      container.read(toolsControllerProvider).ownColorSchemes;

  const incompleteMsg = 'Incomplete Hex Code (Must be 8 characters: AARRGGBB)';

  testWidgets('is initially collapsed', (tester) async {
    await pump(tester);

    expect(find.text('Scheme Adder'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  testWidgets('click expands and collapses', (tester) async {
    await pump(tester);

    await expand(tester);
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(find.text('Scheme Name'), findsOneWidget);
    for (final label in [
      'BackGround',
      'Surface',
      'Accent',
      'Accent Light',
      'Text Primary',
      'Text Secondary',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(TextField), findsNWidgets(7));

    await expand(tester);
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  testWidgets('hex fields are pre-filled with current colors', (tester) async {
    await pump(tester);
    await expand(tester);

    expect(
      textOf(tester, hexField(0)),
      ColorPickerOverlay.colorToHex(kBgColor),
    );
    expect(textOf(tester, hexField(2)), ColorPickerOverlay.colorToHex(kAccent));
    expect(
      textOf(tester, hexField(5)),
      ColorPickerOverlay.colorToHex(kTextSecondary),
    );
  });

  testWidgets('hex field accepts hex characters only', (tester) async {
    await pump(tester);
    await expand(tester);

    await tester.enterText(hexField(0), 'ZZxy12');
    await tester.pump();

    expect(textOf(tester, hexField(0)), '12');
  });

  testWidgets('hex field is limited to 8 characters', (tester) async {
    await pump(tester);
    await expand(tester);

    await tester.enterText(hexField(0), '');
    await tester.pump();

    await tester.enterText(hexField(0), '1234567890');
    await tester.pump();

    expect(textOf(tester, hexField(0)), '12345678');
  });

  testWidgets('name is limited to 24 characters', (tester) async {
    await pump(tester);
    await expand(tester);

    await tester.enterText(nameField(), 'a' * 30);
    await tester.pump();

    expect(textOf(tester, nameField()).length, 24);
  });

  testWidgets('warning appears only after add with incomplete hex', (
    tester,
  ) async {
    await pump(tester);
    await expand(tester);

    await tester.enterText(hexField(0), 'FF00');
    await tester.pump();
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.byTooltip(incompleteMsg), findsOneWidget);
    expect(ownSchemes(), isEmpty);
  });

  testWidgets('multiple invalid fields show multiple warnings', (tester) async {
    await pump(tester);
    await expand(tester);

    await tester.enterText(hexField(0), 'F');
    await tester.enterText(hexField(3), 'AB');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));
  });

  testWidgets('corrected input + add creates scheme, warning disappears', (
    tester,
  ) async {
    await pump(tester);
    await expand(tester);

    await tester.enterText(hexField(0), 'FF00');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    await tester.enterText(nameField(), 'New');
    await tester.enterText(hexField(0), 'FF112233');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    expect(ownSchemes(), hasLength(1));
    expect(ownSchemes().first.name, 'New');
  });

  testWidgets('valid input changes global color live', (tester) async {
    await pump(tester);
    await expand(tester);

    await tester.enterText(hexField(0), 'FF0A0B0C');
    await tester.pump();

    expect(kBgColor, const Color(0xFF0A0B0C));
  });

  testWidgets('click on color swatch opens ColorPicker, OK closes it', (
    tester,
  ) async {
    await pump(tester);
    await expand(tester);

    await tester.tap(swatch().first);
    await tester.pump();
    expect(find.byType(ColorPicker), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pump();
    expect(find.byType(ColorPicker), findsNothing);
  });

  testWidgets('change in ColorPicker updates hex field', (tester) async {
    await pump(tester);
    await expand(tester);

    await tester.tap(swatch().first);
    await tester.pump();
    tester
        .widget<ColorPicker>(find.byType(ColorPicker))
        .onColorChanged(const Color(0xFF223344));
    await tester.pump();

    expect(textOf(tester, hexField(0)), 'FF223344');
    expect(kBgColor, const Color(0xFF223344));
  });
}
