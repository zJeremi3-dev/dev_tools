import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../colors.dart';

class ColorPickerOverlay {
  static OverlayEntry? _overlayEntry;
  static String colorToHex(Color color) {
    return color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  static Color? parseHexColor(String input) {
    if (input.length != 8) return null;
    final intValue = int.tryParse(input, radix: 16);
    if (intValue == null) return null;
    return Color(intValue);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void show({
    required BuildContext context,
    required GlobalKey key,
    required TextEditingController controller,
    required String label,
    required Function(String label, String hexValue) onColorChanged,
  }) {
    hide();

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    // Höhe des ColorPickers inklusive Padding/Buttons (ca. 300px)
    const double pickerHeight = 310;

    // Prüfen, ob nach unten genug Platz ist
    final bool fitsBelow =
        (offset.dy + renderBox.size.height + pickerHeight) <= screenSize.height;

    // Wenn es unten nicht passt, platzieren wir es oberhalb des UI-Elements
    final double topPosition = fitsBelow
        ? offset.dy + renderBox.size.height + 8
        : offset.dy - pickerHeight - 8;

    Color pickerColor = parseHexColor(controller.text) ?? Colors.black;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: hide,
              ),
            ),
            Positioned(
              left: offset.dx,
              top: topPosition, // Dynamic Top Position
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: kSurfaceColor,
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kAccent, width: 1.5),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (color) {
                              setOverlayState(() {
                                pickerColor = color;
                              });
                              final hex = colorToHex(color);
                              controller.text = hex;
                              onColorChanged(label, hex);
                            },
                            portraitOnly: true,
                            pickerAreaHeightPercent: 0.7,
                            enableAlpha: true,
                            displayThumbColor: true,
                            colorPickerWidth: 230,
                            labelTypes: [],
                            paletteType: PaletteType.hslWithHue,
                            pickerAreaBorderRadius: BorderRadius.circular(8),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: hide,
                              child: Text(
                                'OK',
                                style: TextStyle(color: kAccentLight),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}
