import 'package:dev_tools/colors.dart';
import 'package:dev_tools/settings/color_scheme/color_picker_overlay.dart';
import 'package:dev_tools/settings/color_scheme/scheme_adder_controller.dart';
import 'package:dev_tools/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late WidgetRef ref;
  late SchemeAdderController ctrl;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    applyColorScheme(1);
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  /// The controller needs a WidgetRef -> access via Consumer widget.
  Future<void> pumpController(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Consumer(
            builder: (context, r, _) {
              ref = r;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    ctrl = SchemeAdderController(ref);
    addTearDown(ctrl.dispose);
  }

  List<dynamic> ownSchemes() =>
      container.read(toolsControllerProvider).ownColorSchemes;

  String hex(Color c) => ColorPickerOverlay.colorToHex(c);

  testWidgets('controllers are initialized with current global colors', (
    tester,
  ) async {
    await pumpController(tester);

    expect(ctrl.bgController.text, hex(kBgColor));
    expect(ctrl.surfaceController.text, hex(kSurfaceColor));
    expect(ctrl.accentController.text, hex(kAccent));
    expect(ctrl.accentLightController.text, hex(kAccentLight));
    expect(ctrl.textPrimaryController.text, hex(kTextPrimary));
    expect(ctrl.textSecondaryController.text, hex(kTextSecondary));
    expect(ctrl.nameController.text, isEmpty);
  });

  testWidgets('all error flags start at 0', (tester) async {
    await pumpController(tester);

    expect([
      ctrl.bgError,
      ctrl.surfaceError,
      ctrl.accentError,
      ctrl.accentLightError,
      ctrl.textPrimaryError,
      ctrl.textSecondaryError,
    ], everyElement(0));
  });

  testWidgets('updateControllersFromGlobals overwrites manual inputs', (
    tester,
  ) async {
    await pumpController(tester);
    ctrl.bgController.text = 'DEADBEEF';
    ctrl.accentController.text = '12';

    ctrl.updateControllersFromGlobals();

    expect(ctrl.bgController.text, hex(kBgColor));
    expect(ctrl.accentController.text, hex(kAccent));
  });

  group('validateAndAddScheme', () {
    testWidgets('invalid field -> false, flag set, nothing added', (
      tester,
    ) async {
      await pumpController(tester);
      ctrl.bgController.text = 'FF'; // too short
      var rebuilds = 0;

      final result = ctrl.validateAndAddScheme(() => rebuilds++);
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(rebuilds, 1);
      expect(ctrl.bgError, 1);
      expect(ctrl.surfaceError, 0);
      expect(ctrl.accentError, 0);
      expect(ownSchemes(), isEmpty);
    });

    testWidgets('multiple invalid fields are all flagged', (tester) async {
      await pumpController(tester);
      ctrl.surfaceController.text = 'ZZZZZZZZ';
      ctrl.textPrimaryController.text = '';
      ctrl.textSecondaryController.text = '123456789';

      final result = ctrl.validateAndAddScheme(() {});

      expect(result, isFalse);
      expect(ctrl.bgError, 0);
      expect(ctrl.surfaceError, 1);
      expect(ctrl.accentError, 0);
      expect(ctrl.accentLightError, 0);
      expect(ctrl.textPrimaryError, 1);
      expect(ctrl.textSecondaryError, 1);
      expect(ownSchemes(), isEmpty);
    });

    testWidgets('valid inputs -> true and scheme is created', (tester) async {
      await pumpController(tester);
      ctrl.nameController.text = 'Test';
      ctrl.accentController.text = 'FF123456';

      final result = ctrl.validateAndAddScheme(() {});
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(ownSchemes(), hasLength(1));
      expect(ownSchemes().first.name, 'Test');
      expect(ownSchemes().first.accent, const Color(0xFF123456));
    });

    testWidgets('error flags are reset after corrected input', (tester) async {
      await pumpController(tester);
      ctrl.bgController.text = 'FF';
      ctrl.validateAndAddScheme(() {});
      expect(ctrl.bgError, 1);

      ctrl.bgController.text = 'FF000000';
      final result = ctrl.validateAndAddScheme(() {});

      expect(result, isTrue);
      expect(ctrl.bgError, 0);
    });
  });

  group('onColorChanged', () {
    testWidgets('valid hex -> global color is set, no rebuild', (tester) async {
      await pumpController(tester);
      var rebuilds = 0;

      // Assumption: applyTestScheme('BackGround', c) sets kBgColor.
      ctrl.onColorChanged('BackGround', 'FF112233', () => rebuilds++);

      expect(kBgColor, const Color(0xFF112233));
      expect(rebuilds, 0);
    });

    testWidgets('valid hex notifies ToolsController', (tester) async {
      await pumpController(tester);
      var notified = 0;
      final tools = container.read(toolsControllerProvider);
      void listener() => notified++;
      tools.addListener(listener);
      addTearDown(() => tools.removeListener(listener));

      ctrl.onColorChanged('Accent', 'FF445566', () {});

      expect(notified, greaterThanOrEqualTo(1));
    });

    testWidgets('incomplete hex -> rebuild, colors remain unchanged', (
      tester,
    ) async {
      await pumpController(tester);
      final before = kBgColor;
      var rebuilds = 0;

      ctrl.onColorChanged('BackGround', 'FF11', () => rebuilds++);

      expect(rebuilds, 1);
      expect(kBgColor, before);
    });
  });

  testWidgets('dispose disposes all TextEditingControllers', (tester) async {
    await pumpController(tester);
    final extra = SchemeAdderController(ref);

    extra.dispose();

    // Accessing a disposed controller throws in debug builds.
    expect(() => extra.nameController.addListener(() {}), throwsFlutterError);
  });
}
