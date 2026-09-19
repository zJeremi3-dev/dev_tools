import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/models/tool_module.dart';
import 'package:dev_tools/settings/hidden_modules.dart';

void main() {
  final visible = [
    ToolModule(
      id: 1,
      name: 'Visible Tool',
      description: 'd',
      icon: Icons.build,
      category: 'Test',
      dialogBuilder: (c) => const SizedBox(),
    ),
  ];
  final hidden = [
    ToolModule(
      id: 2,
      name: 'Hidden Tool',
      description: 'd',
      icon: Icons.build,
      category: 'Test',
      dialogBuilder: (c) => const SizedBox(),
    ),
  ];

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('starts collapsed: dropdown and list are hidden', (tester) async {
    await tester.pumpWidget(
      wrap(
        HiddenModulesSection(
          visibleTools: visible,
          hiddenTools: hidden,
          onHide: (_) {},
          onUnHide: (_) {},
        ),
      ),
    );

    expect(find.byType(DropdownButtonFormField<double>), findsNothing);
    expect(find.text(' Hidden Tool'), findsNothing);
  });

  testWidgets('expanding reveals the dropdown and the hidden list', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        HiddenModulesSection(
          visibleTools: visible,
          hiddenTools: hidden,
          onHide: (_) {},
          onUnHide: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Hidden Modules'));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<double>), findsOneWidget);
    expect(find.text(' Hidden Tool'), findsOneWidget);
  });

  testWidgets('shows a placeholder when nothing is hidden', (tester) async {
    await tester.pumpWidget(
      wrap(
        HiddenModulesSection(
          visibleTools: visible,
          hiddenTools: const [],
          onHide: (_) {},
          onUnHide: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Hidden Modules'));
    await tester.pumpAndSettle();

    expect(find.text('No hidden modules'), findsOneWidget);
  });

  testWidgets('selecting a tool from the dropdown calls onHide', (
    tester,
  ) async {
    double? hiddenId;
    await tester.pumpWidget(
      wrap(
        HiddenModulesSection(
          visibleTools: visible,
          hiddenTools: hidden,
          onHide: (id) => hiddenId = id,
          onUnHide: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Hidden Modules'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<double>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visible Tool').last);
    await tester.pumpAndSettle();

    expect(hiddenId, 1.0);
  });

  testWidgets('tapping a hidden tool calls onUnHide', (tester) async {
    double? unhiddenId;
    await tester.pumpWidget(
      wrap(
        HiddenModulesSection(
          visibleTools: visible,
          hiddenTools: hidden,
          onHide: (_) {},
          onUnHide: (id) => unhiddenId = id,
        ),
      ),
    );

    await tester.tap(find.text('Hidden Modules'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(' Hidden Tool'));
    await tester.pumpAndSettle();

    expect(unhiddenId, 2.0);
  });
}
