import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_tools/app/home_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});

    // flutter_native_splash calls a platform channel to hide the splash
    // screen; there's no real platform in a widget test, so it's stubbed
    // out to avoid a MissingPluginException interrupting the test. If
    // this fails after a package upgrade, check the channel name the
    // installed flutter_native_splash version actually uses.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_native_splash'),
          (call) async => null,
        );
  });

  Widget wrap() => const ProviderScope(
    child: MaterialApp(home: MyHomePage(title: 'Dev-Tools')),
  );

  testWidgets('app loads and shows the tool list', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    expect(find.text('Dev-Tools'), findsOneWidget);
    expect(find.text('Password Generator'), findsOneWidget);
    expect(find.text('Settings'), findsNothing); // dialog not open yet
  });

  testWidgets('typing in the search bar filters the tool list', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), 'password');
    await tester.pumpAndSettle();

    expect(find.text('Password Generator'), findsOneWidget);
    expect(find.text('QR-Code Generator'), findsNothing);
  });

  testWidgets('opening settings shows the settings dialog', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });
}
