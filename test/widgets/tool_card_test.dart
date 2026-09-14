import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/models/tool_module.dart';
import 'package:dev_tools/widgets/tool_card.dart';

void main() {
  final testModule = ToolModule(
    id: 1,
    name: 'Test Tool',
    description: 'A tool used only for testing',
    icon: Icons.build,
    category: 'Test',
    dialogBuilder: (context) => AlertDialog(
      title: const Text('Test Dialog'),
      content: const Text('Dialog content'),
    ),
  );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders name, description and icon', (tester) async {
    await tester.pumpWidget(
      wrap(
        ToolCard(
          module: testModule,
          isFavorite: false,
          onToggleFavorite: () {},
          onSecondaryTapDown: (_) {},
        ),
      ),
    );

    expect(find.text('Test Tool'), findsOneWidget);
    expect(find.text('A tool used only for testing'), findsOneWidget);
    expect(find.byIcon(Icons.build), findsOneWidget);
  });

  testWidgets('shows outlined star when not favorite', (tester) async {
    await tester.pumpWidget(
      wrap(
        ToolCard(
          module: testModule,
          isFavorite: false,
          onToggleFavorite: () {},
          onSecondaryTapDown: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
  });

  testWidgets('shows filled star when favorite', (tester) async {
    await tester.pumpWidget(
      wrap(
        ToolCard(
          module: testModule,
          isFavorite: true,
          onToggleFavorite: () {},
          onSecondaryTapDown: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_border_rounded), findsNothing);
  });

  testWidgets('tapping the star calls onToggleFavorite exactly once', (
    tester,
  ) async {
    var callCount = 0;
    await tester.pumpWidget(
      wrap(
        ToolCard(
          module: testModule,
          isFavorite: false,
          onToggleFavorite: () => callCount++,
          onSecondaryTapDown: (_) {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star_border_rounded));
    await tester.pump();

    expect(callCount, 1);
  });

  testWidgets('tapping the star does not also open the tool dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ToolCard(
          module: testModule,
          isFavorite: false,
          onToggleFavorite: () {},
          onSecondaryTapDown: (_) {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star_border_rounded));
    await tester.pumpAndSettle();

    // The star sits on its own opaque hit-test area, so tapping it
    // must not bubble through to the card's onTap (which opens the dialog).
    expect(find.text('Test Dialog'), findsNothing);
  });

  testWidgets('tapping the card body opens the tool dialog', (tester) async {
    await tester.pumpWidget(
      wrap(
        ToolCard(
          module: testModule,
          isFavorite: false,
          onToggleFavorite: () {},
          onSecondaryTapDown: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Test Tool'));
    await tester.pumpAndSettle();

    expect(find.text('Test Dialog'), findsOneWidget);
    expect(find.text('Dialog content'), findsOneWidget);
  });

  testWidgets('right-click / secondary tap reports the tap position', (
    tester,
  ) async {
    Offset? reportedPosition;
    await tester.pumpWidget(
      wrap(
        ToolCard(
          module: testModule,
          isFavorite: false,
          onToggleFavorite: () {},
          onSecondaryTapDown: (pos) => reportedPosition = pos,
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Test Tool')),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.up();
    await tester.pump();

    expect(reportedPosition, isNotNull);
  });

  testWidgets('long tool name is truncated with ellipsis, not wrapped', (
    tester,
  ) async {
    final longNameModule = ToolModule(
      id: 2,
      name: 'A Very Long Tool Name That Should Not Wrap Across Lines',
      description: 'desc',
      icon: Icons.build,
      category: 'Test',
      dialogBuilder: (context) => const SizedBox(),
    );

    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 200, // deliberately narrow to force truncation
          child: ToolCard(
            module: longNameModule,
            isFavorite: false,
            onToggleFavorite: () {},
            onSecondaryTapDown: (_) {},
          ),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.text(longNameModule.name));
    expect(textWidget.maxLines, 1);
    expect(textWidget.overflow, TextOverflow.ellipsis);
  });
}
