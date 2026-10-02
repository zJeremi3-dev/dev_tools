import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../colors.dart';
import '../../own_colors.dart';
import '../../state/providers.dart';
import 'color_picker_overlay.dart';

class SchemeAdderController {
  final WidgetRef ref;

  final nameController = TextEditingController();
  late final TextEditingController bgController;
  late final TextEditingController surfaceController;
  late final TextEditingController accentController;
  late final TextEditingController accentLightController;
  late final TextEditingController textPrimaryController;
  late final TextEditingController textSecondaryController;

  int bgError = 0;
  int surfaceError = 0;
  int accentError = 0;
  int accentLightError = 0;
  int textPrimaryError = 0;
  int textSecondaryError = 0;

  SchemeAdderController(this.ref) {
    bgController = TextEditingController(
      text: ColorPickerOverlay.colorToHex(kBgColor),
    );
    surfaceController = TextEditingController(
      text: ColorPickerOverlay.colorToHex(kSurfaceColor),
    );
    accentController = TextEditingController(
      text: ColorPickerOverlay.colorToHex(kAccent),
    );
    accentLightController = TextEditingController(
      text: ColorPickerOverlay.colorToHex(kAccentLight),
    );
    textPrimaryController = TextEditingController(
      text: ColorPickerOverlay.colorToHex(kTextPrimary),
    );
    textSecondaryController = TextEditingController(
      text: ColorPickerOverlay.colorToHex(kTextSecondary),
    );
  }

  void updateControllersFromGlobals() {
    bgController.text = ColorPickerOverlay.colorToHex(kBgColor);
    surfaceController.text = ColorPickerOverlay.colorToHex(kSurfaceColor);
    accentController.text = ColorPickerOverlay.colorToHex(kAccent);
    accentLightController.text = ColorPickerOverlay.colorToHex(kAccentLight);
    textPrimaryController.text = ColorPickerOverlay.colorToHex(kTextPrimary);
    textSecondaryController.text = ColorPickerOverlay.colorToHex(
      kTextSecondary,
    );
  }

  void dispose() {
    nameController.dispose();
    bgController.dispose();
    surfaceController.dispose();
    accentController.dispose();
    accentLightController.dispose();
    textPrimaryController.dispose();
    textSecondaryController.dispose();
  }

  bool validateAndAddScheme(VoidCallback rebuildUi) {
    final bg = ColorPickerOverlay.parseHexColor(bgController.text);
    final surface = ColorPickerOverlay.parseHexColor(surfaceController.text);
    final accent = ColorPickerOverlay.parseHexColor(accentController.text);
    final accentLight = ColorPickerOverlay.parseHexColor(
      accentLightController.text,
    );
    final textPrimary = ColorPickerOverlay.parseHexColor(
      textPrimaryController.text,
    );
    final textSecondary = ColorPickerOverlay.parseHexColor(
      textSecondaryController.text,
    );

    rebuildUi();
    bgError = (bg == null) ? 1 : 0;
    surfaceError = (surface == null) ? 1 : 0;
    accentError = (accent == null) ? 1 : 0;
    accentLightError = (accentLight == null) ? 1 : 0;
    textPrimaryError = (textPrimary == null) ? 1 : 0;
    textSecondaryError = (textSecondary == null) ? 1 : 0;

    if ([
      bg,
      surface,
      accent,
      accentLight,
      textPrimary,
      textSecondary,
    ].any((v) => v == null)) {
      return false;
    }

    ref
        .read(toolsControllerProvider)
        .addOwnColorScheme(
          name: nameController.text,
          bg: bg!,
          surface: surface!,
          accent: accent!,
          accentLight: accentLight!,
          textPrimary: textPrimary!,
          textSecondary: textSecondary!,
        );
    return true;
  }

  void onColorChanged(String label, String value, VoidCallback rebuildUi) {
    final parsedColor = ColorPickerOverlay.parseHexColor(value);
    if (parsedColor != null) {
      applyTestScheme(label, parsedColor);
      ref.read(toolsControllerProvider).singleChangeNotifier();
    } else {
      rebuildUi();
    }
  }
}
