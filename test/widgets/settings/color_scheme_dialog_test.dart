import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_tools/colors.dart';
import 'package:dev_tools/settings/color_scheme_dialog.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    applyColorScheme(1); // reset global color state before each test
  });

  Widget wrap() => const ProviderScope(
    child: MaterialApp(home: Scaffold(body: ColorSchemeDialog())),
  );

  testWidgets('shows every color scheme as a tappable swatch', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.byTooltip('Violet'), findsOneWidget);
    expect(find.byTooltip('Ocean Blue'), findsOneWidget);
    expect(find.byTooltip('Berry Wine'), findsOneWidget);
  });

  testWidgets('the initially selected scheme shows a checkmark', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    expect(
      find.descendant(
        of: find.byTooltip('Violet'),
        matching: find.byIcon(Icons.check_box),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping another scheme applies and marks it selected', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byTooltip('Ocean Blue'));
    await tester.pump();

    expect(selectedScheme, 2);
    expect(
      find.descendant(
        of: find.byTooltip('Ocean Blue'),
        matching: find.byIcon(Icons.check_box),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byTooltip('Violet'),
        matching: find.byIcon(Icons.check_box),
      ),
      findsNothing,
    );
  });

  testWidgets('close button dismisses the dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const ColorSchemeDialog(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Color Scheme'), findsNothing);
  });
}
