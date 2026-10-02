import 'package:dev_tools/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Large test surface so dialogs/wraps do not overflow the default size (800x600).
/// Resets automatically.
void useLargeSurface(
  WidgetTester tester, {
  Size size = const Size(1000, 1600),
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Creates a custom color scheme using the real controller.
void addOwnScheme(
  ProviderContainer container, {
  String name = 'Mine',
  Color accent = const Color(0xFF00FF00),
}) {
  container
      .read(toolsControllerProvider)
      .addOwnColorScheme(
        name: name,
        bg: const Color(0xFF101010),
        surface: const Color(0xFF202020),
        accent: accent,
        accentLight: const Color(0xFF66FF66),
        textPrimary: const Color(0xFFFFFFFF),
        textSecondary: const Color(0xFFAAAAAA),
      );
}

int firstOwnSchemeId(ProviderContainer container) =>
    container.read(toolsControllerProvider).ownColorSchemes.first.id;

Widget appWith(ProviderContainer container, Widget home) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: Scaffold(body: home)),
  );
}

/// Opens [builder] via showDialog (like in the real app) so
/// Navigator.pop() works in the dialog.
Future<void> openInDialog(
  WidgetTester tester,
  ProviderContainer container,
  WidgetBuilder builder,
) async {
  await tester.pumpWidget(
    appWith(
      container,
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog(
            context: context,
            builder: builder,
            useRootNavigator: true,
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
