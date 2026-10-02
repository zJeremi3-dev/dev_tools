import 'package:dev_tools/settings/color_scheme/color_picker_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('colorToHex', () {
    test('formats as 8-digit ARGB in uppercase', () {
      expect(ColorPickerOverlay.colorToHex(Colors.black), 'FF000000');
      expect(
        ColorPickerOverlay.colorToHex(const Color(0xFFABCDEF)),
        'FFABCDEF',
      );
    });

    test('pads leading zeros (Alpha 0)', () {
      expect(
        ColorPickerOverlay.colorToHex(const Color(0x00000000)),
        '00000000',
      );
      expect(
        ColorPickerOverlay.colorToHex(const Color(0x0A0B0C0D)),
        '0A0B0C0D',
      );
    });
  });

  group('parseHexColor', () {
    test('parses valid 8-digit hex strings', () {
      expect(
        ColorPickerOverlay.parseHexColor('FF112233'),
        const Color(0xFF112233),
      );
      expect(
        ColorPickerOverlay.parseHexColor('00000000'),
        const Color(0x00000000),
      );
    });

    test('is case-insensitive', () {
      expect(
        ColorPickerOverlay.parseHexColor('ffaabbcc'),
        const Color(0xFFAABBCC),
      );
    });

    test('returns null for invalid length', () {
      expect(ColorPickerOverlay.parseHexColor(''), isNull);
      expect(ColorPickerOverlay.parseHexColor('FF'), isNull);
      expect(ColorPickerOverlay.parseHexColor('FF11223'), isNull);
      expect(ColorPickerOverlay.parseHexColor('FF1122334'), isNull);
      expect(ColorPickerOverlay.parseHexColor('0xFF112233'), isNull);
    });

    test('returns null for invalid characters', () {
      expect(ColorPickerOverlay.parseHexColor('GGGGGGGG'), isNull);
      expect(ColorPickerOverlay.parseHexColor('FF11 233'), isNull);
    });

    test('roundtrip colorToHex -> parseHexColor', () {
      const c = Color(0x80123456);
      expect(
        ColorPickerOverlay.parseHexColor(ColorPickerOverlay.colorToHex(c)),
        c,
      );
    });
  });

  group('Overlay', () {
    final anchorKey = GlobalKey();
    late BuildContext ctx;
    late TextEditingController controller;

    Future<void> pumpHarness(
      WidgetTester tester, {
      Alignment anchorAlignment = Alignment.topLeft,
    }) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (c) {
                ctx = c;
                return Align(
                  alignment: anchorAlignment,
                  child: SizedBox(key: anchorKey, width: 100, height: 40),
                );
              },
            ),
          ),
        ),
      );
    }

    void show({Function(String, String)? onChanged, GlobalKey? key}) {
      ColorPickerOverlay.show(
        context: ctx,
        key: key ?? anchorKey,
        controller: controller,
        label: 'Accent',
        onColorChanged: onChanged ?? (_, _) {},
      );
    }

    setUp(() => controller = TextEditingController(text: 'FF112233'));

    tearDown(() {
      ColorPickerOverlay.hide();
      controller.dispose();
    });

    testWidgets('show displays the ColorPicker with OK button', (tester) async {
      await pumpHarness(tester);
      show();
      await tester.pump();

      expect(find.byType(ColorPicker), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('OK closes the overlay', (tester) async {
      await pumpHarness(tester);
      show();
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pump();

      expect(find.byType(ColorPicker), findsNothing);
    });

    testWidgets('tapping outside closes the overlay', (tester) async {
      await pumpHarness(tester);
      show();
      await tester.pump();

      await tester.tapAt(const Offset(10, 590));
      await tester.pump();

      expect(find.byType(ColorPicker), findsNothing);
    });

    testWidgets('hide() is idempotent and removes the overlay', (tester) async {
      await pumpHarness(tester);
      ColorPickerOverlay.hide(); // no open overlay: no error
      show();
      await tester.pump();

      ColorPickerOverlay.hide();
      ColorPickerOverlay.hide();
      await tester.pump();

      expect(find.byType(ColorPicker), findsNothing);
    });

    testWidgets(
      'calling show again replaces the old overlay (only one visible)',
      (tester) async {
        await pumpHarness(tester);
        show();
        await tester.pump();
        show();
        await tester.pump();

        expect(find.byType(ColorPicker), findsOneWidget);
      },
    );

    testWidgets('does nothing without mounted anchor widget', (tester) async {
      await pumpHarness(tester);
      show(key: GlobalKey()); // Key is not attached to any widget
      await tester.pump();

      expect(find.byType(ColorPicker), findsNothing);
    });

    testWidgets('initial color comes from controller text', (tester) async {
      await pumpHarness(tester);
      show();
      await tester.pump();

      expect(
        tester.widget<ColorPicker>(find.byType(ColorPicker)).pickerColor,
        const Color(0xFF112233),
      );
    });

    testWidgets('invalid controller text -> initial color Black', (
      tester,
    ) async {
      controller.text = 'XYZ';
      await pumpHarness(tester);
      show();
      await tester.pump();

      expect(
        tester.widget<ColorPicker>(find.byType(ColorPicker)).pickerColor,
        Colors.black,
      );
    });

    testWidgets('color change writes hex to controller and invokes callback', (
      tester,
    ) async {
      await pumpHarness(tester);
      String? gotLabel;
      String? gotHex;
      show(
        onChanged: (l, h) {
          gotLabel = l;
          gotHex = h;
        },
      );
      await tester.pump();

      tester
          .widget<ColorPicker>(find.byType(ColorPicker))
          .onColorChanged(const Color(0xFF123456));
      await tester.pump();

      expect(controller.text, 'FF123456');
      expect(gotLabel, 'Accent');
      expect(gotHex, 'FF123456');
      expect(
        tester.widget<ColorPicker>(find.byType(ColorPicker)).pickerColor,
        const Color(0xFF123456),
      );
    });

    testWidgets('space available below -> picker appears below', (
      tester,
    ) async {
      await pumpHarness(tester, anchorAlignment: Alignment.topLeft);
      show();
      await tester.pump();

      final anchorBottom = tester.getBottomLeft(find.byKey(anchorKey)).dy;
      final pickerTop = tester
          .getTopLeft(
            find
                .ancestor(
                  of: find.byType(ColorPicker),
                  matching: find.byType(Material),
                )
                .first,
          )
          .dy;

      expect(pickerTop, anchorBottom + 8);
    });

    testWidgets('no space below -> picker appears above', (tester) async {
      await pumpHarness(tester, anchorAlignment: Alignment.bottomLeft);
      show();
      await tester.pump();

      final anchorTop = tester.getTopLeft(find.byKey(anchorKey)).dy;
      final pickerTop = tester
          .getTopLeft(
            find
                .ancestor(
                  of: find.byType(ColorPicker),
                  matching: find.byType(Material),
                )
                .first,
          )
          .dy;

      expect(pickerTop, anchorTop - 310 - 8);
    });
  });
}
