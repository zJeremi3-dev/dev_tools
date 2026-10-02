import 'package:dev_tools/colors.dart';
import 'package:dev_tools/settings/color_scheme/color_scheme_dialog.dart';
import 'package:dev_tools/settings/color_scheme/modify_ownscheme_dialog.dart';
import 'package:dev_tools/settings/color_scheme/scheme_adder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_tools/own_colors.dart';

import 'test_helpers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    applyColorScheme(1); // reset global color state before each test
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  Widget wrap() => appWith(container, const ColorSchemeDialog());

  Finder checkIn(String tooltip) => find.descendant(
    of: find.byTooltip(tooltip),
    matching: find.byIcon(Icons.check_box),
  );

  group('Standard Schemes', () {
    testWidgets('shows every color scheme as a tappable swatch', (
      tester,
    ) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());

      expect(kColorSchemes, isNotEmpty);
      for (final s in kColorSchemes) {
        expect(find.byTooltip(s.name), findsOneWidget, reason: s.name);
      }
    });

    testWidgets('the initially selected scheme shows a checkmark', (
      tester,
    ) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());

      expect(checkIn('Violet'), findsOneWidget);
      // exactly one checkmark in the entire dialog
      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });

    testWidgets('tapping another scheme applies and marks it selected', (
      tester,
    ) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());

      await tester.tap(find.byTooltip('Ocean Blue'));
      await tester.pump();

      expect(selectedScheme, 2);
      expect(checkIn('Ocean Blue'), findsOneWidget);
      expect(checkIn('Violet'), findsNothing);
      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });

    testWidgets('tapping the selected scheme again changes nothing', (
      tester,
    ) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());

      await tester.tap(find.byTooltip('Violet'));
      await tester.pump();

      expect(selectedScheme, 1);
      expect(checkIn('Violet'), findsOneWidget);
    });
  });

  group('Own Schemes', () {
    testWidgets(
      '"Own Schemes" section is hidden when no custom schemes exist',
      (tester) async {
        useLargeSurface(tester);
        await tester.pumpWidget(wrap());

        expect(find.text('Own Schemes'), findsNothing);
      },
    );

    testWidgets('section appears as soon as a custom scheme exists', (
      tester,
    ) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      addOwnScheme(container, name: 'Mine');
      await tester.pumpAndSettle();

      expect(find.text('Own Schemes'), findsOneWidget);
      expect(find.byTooltip('Mine'), findsOneWidget);
    });

    testWidgets('tapping custom scheme selects it', (tester) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      addOwnScheme(container, name: 'Mine');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mine'));
      await tester.pumpAndSettle();

      expect(selectedOwnScheme, firstOwnSchemeId(container));
      expect(checkIn('Mine'), findsOneWidget);
    });

    testWidgets('multiple custom schemes are all displayed', (tester) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      addOwnScheme(container, name: 'One');
      addOwnScheme(container, name: 'Two');
      await tester.pumpAndSettle();

      expect(find.byTooltip('One'), findsOneWidget);
      expect(find.byTooltip('Two'), findsOneWidget);
    });

    testWidgets('hover shows edit panel, click opens modify dialog', (
      tester,
    ) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      addOwnScheme(container, name: 'Mine');
      await tester.pumpAndSettle();
      // open via showDialog so Navigator.pop works in the dialog
      await openInDialog(tester, container, (_) => const ColorSchemeDialog());

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byTooltip('Mine')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.drive_file_rename_outline_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ModifyOwnSchemeDialog), findsOneWidget);
      expect(find.byType(ColorSchemeDialog), findsNothing);
    });
  });

  group('General', () {
    testWidgets('shows title and the scheme adder', (tester) async {
      useLargeSurface(tester);
      await tester.pumpWidget(wrap());

      expect(find.text('Color Scheme'), findsOneWidget);
      expect(find.text('Schemes'), findsOneWidget);
      expect(find.byType(SchemeAdderSection), findsOneWidget);
    });

    Future<void> openDialog(WidgetTester tester) async {
      useLargeSurface(tester);
      await openInDialog(tester, container, (_) => const ColorSchemeDialog());
      expect(find.text('Color Scheme'), findsOneWidget);
    }

    testWidgets('close button dismisses the dialog', (tester) async {
      await openDialog(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Color Scheme'), findsNothing);
    });

    testWidgets('"Close" text button closes the dialog', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Color Scheme'), findsNothing);
    });
  });
}
