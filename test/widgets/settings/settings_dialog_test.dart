import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_tools/models/tool_module.dart';
import 'package:dev_tools/settings/settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final tools = [
    ToolModule(
      id: 1,
      name: 'Tool One',
      description: 'desc',
      icon: Icons.build,
      category: 'Test',
      dialogBuilder: (context) => const SizedBox(),
    ),
    ToolModule(
      id: 2,
      name: 'Tool Two',
      description: 'desc',
      icon: Icons.build,
      category: 'Test',
      dialogBuilder: (context) => const SizedBox(),
    ),
  ];

  Future<void> openSettings(
    WidgetTester tester, {
    List<double> hideOrder = const [],
    void Function(double id)? onHide,
    void Function(double id)? onUnHide,
    int moduleLayout = 1,
    void Function(int type)? onLayoutChange,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => SettingsDialog(
                    tools: tools,
                    hideOrder: hideOrder,
                    onHide: onHide ?? (_) {},
                    onUnHide: onUnHide ?? (_) {},
                    moduleLayout: moduleLayout,
                    onLayoutChange: onLayoutChange,
                  ),
                  useRootNavigator: true,
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
  }

  testWidgets('shows the settings title and both sections', (tester) async {
    await openSettings(tester);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Hidden Modules'), findsOneWidget);
    expect(find.text('Module Layout'), findsOneWidget);
  });

  testWidgets('close button dismisses the dialog', (tester) async {
    await openSettings(tester);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('hiding a tool via the section forwards to onHide', (
    tester,
  ) async {
    double? hiddenId;
    await openSettings(tester, onHide: (id) => hiddenId = id);

    await tester.tap(find.text('Hidden Modules'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<double>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tool One').last);
    await tester.pumpAndSettle();

    expect(hiddenId, 1.0);
  });

  testWidgets('changing the layout forwards to onLayoutChange', (tester) async {
    int? newLayout;
    await openSettings(tester, onLayoutChange: (type) => newLayout = type);

    await tester.tap(find.byType(Checkbox).at(1)); // "Category"
    await tester.pumpAndSettle();

    expect(newLayout, 2);
  });

  testWidgets(
    'opening color scheme closes settings and opens the color picker',
    (tester) async {
      await openSettings(tester);

      await tester.tap(find.text('Color Scheme'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
      expect(
        find.text('Color Scheme'),
        findsOneWidget,
      ); // now the dialog's own title
    },
  );
}
