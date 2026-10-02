import 'package:dev_tools/colors.dart';
import 'package:dev_tools/settings/color_scheme/color_scheme_dialog.dart';
import 'package:dev_tools/settings/color_scheme/modify_ownscheme_dialog.dart';
import 'package:dev_tools/state/providers.dart';
import 'package:dev_tools/widgets/widgets.dart';
import 'package:flutter/material.dart';
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
    addOwnScheme(container, name: 'Mine');
  });

  tearDown(() => container.dispose());

  List<dynamic> ownSchemes() =>
      container.read(toolsControllerProvider).ownColorSchemes;

  Future<void> openModify(WidgetTester tester, {int? id}) async {
    useLargeSurface(tester);
    await tester.pumpWidget(
      appWith(container, const SizedBox()),
    ); // init Provider
    await tester.pumpAndSettle();
    final schemeId = id ?? firstOwnSchemeId(container);
    await openInDialog(
      tester,
      container,
      (_) => ModifyOwnSchemeDialog(schemeId: schemeId),
    );
  }

  testWidgets('shows title with scheme name and rename hint', (tester) async {
    await openModify(tester);

    expect(find.text('Modify Mine'), findsOneWidget);
    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('now: Mine'), findsOneWidget);
  });

  testWidgets('renaming updates scheme and title', (tester) async {
    await openModify(tester);

    await tester.enterText(find.byType(TextField), 'Renamed');
    await tester.tap(find.byIcon(Icons.drive_file_rename_outline_outlined));
    await tester.pumpAndSettle();

    expect(ownSchemes().first.name, 'Renamed');
    expect(find.text('Modify Renamed'), findsOneWidget);
  });

  testWidgets('deleting removes scheme and opens color scheme dialog', (
    tester,
  ) async {
    await openModify(tester);

    await tester.tap(find.byIcon(Icons.delete_forever));
    await tester.pumpAndSettle();

    expect(ownSchemes(), isEmpty);
    expect(find.byType(ModifyOwnSchemeDialog), findsNothing);
    expect(find.byType(ColorSchemeDialog), findsOneWidget);
  });

  testWidgets('close icon returns to color scheme dialog without changes', (
    tester,
  ) async {
    await openModify(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(ModifyOwnSchemeDialog), findsNothing);
    expect(find.byType(ColorSchemeDialog), findsOneWidget);
    expect(ownSchemes(), hasLength(1));
  });

  testWidgets('close button returns to color scheme dialog', (tester) async {
    await openModify(tester);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(ModifyOwnSchemeDialog), findsNothing);
    expect(find.byType(ColorSchemeDialog), findsOneWidget);
  });

  testWidgets('unknown scheme ID renders nothing', (tester) async {
    await openModify(tester, id: 987654);

    expect(find.byType(ResponsiveDialog), findsNothing);
    expect(find.textContaining('Modify'), findsNothing);
  });
}
