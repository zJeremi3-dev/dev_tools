import 'package:dev_tools/widgets/shared_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../colors.dart';
import 'package:flutter/material.dart';

import '../../state/providers.dart';
import '../../own_colors.dart';

class SchemeAdderSection extends ConsumerStatefulWidget {
  // Variables
  const SchemeAdderSection({
    super.key,
    // Variables -> Parameters
  });

  @override
  ConsumerState<SchemeAdderSection> createState() => _SchemeAdderSectionState();
}

class _SchemeAdderSectionState extends ConsumerState<SchemeAdderSection> {
  bool _adderExpanded = false;

  String _colorToHex(Color color) {
    return color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
  }

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

  @override
  void initState() {
    super.initState();
    bgController = TextEditingController(text: _colorToHex(kBgColor));
    surfaceController = TextEditingController(text: _colorToHex(kSurfaceColor));
    accentController = TextEditingController(text: _colorToHex(kAccent));
    accentLightController = TextEditingController(
      text: _colorToHex(kAccentLight),
    );
    textPrimaryController = TextEditingController(
      text: _colorToHex(kTextPrimary),
    );
    textSecondaryController = TextEditingController(
      text: _colorToHex(kTextSecondary),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    bgController.dispose();
    surfaceController.dispose();
    accentController.dispose();
    accentLightController.dispose();
    textPrimaryController.dispose();
    textSecondaryController.dispose();
    super.dispose();
  }

  Color? parseHexColor(String input) {
    if (input.length != 8) return null;
    final intValue = int.tryParse(input, radix: 16);
    if (intValue == null) return null;
    return Color(intValue);
  }

  int addTest() {
    final bg = parseHexColor(bgController.text);
    final surface = parseHexColor(surfaceController.text);
    final accent = parseHexColor(accentController.text);
    final accentLight = parseHexColor(accentLightController.text);
    final textPrimary = parseHexColor(textPrimaryController.text);
    final textSecondary = parseHexColor(textSecondaryController.text);
    setState(() {
      bgError = (bg == null) ? 1 : 0;
      surfaceError = (surface == null) ? 1 : 0;
      accentError = (accent == null) ? 1 : 0;
      accentLightError = (accentLight == null) ? 1 : 0;
      textPrimaryError = (textPrimary == null) ? 1 : 0;
      textSecondaryError = (textSecondary == null) ? 1 : 0;
    });
    if ([
      bg,
      surface,
      accent,
      accentLight,
      textPrimary,
      textSecondary,
    ].any((v) => v == null)) {
      return 0;
    }
    return 1;
  }

  void _onColorChanged(String label, String value) {
    final parsedColor = parseHexColor(value);
    if (parsedColor != null) {
      applyTestScheme(label, parsedColor);
      ref.read(toolsControllerProvider).singleChangeNotifier();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(toolsControllerProvider, (previous, next) {
      bgController.text = _colorToHex(kBgColor);
      surfaceController.text = _colorToHex(kSurfaceColor);
      accentController.text = _colorToHex(kAccent);
      accentLightController.text = _colorToHex(kAccentLight);
      textPrimaryController.text = _colorToHex(kTextPrimary);
      textSecondaryController.text = _colorToHex(kTextSecondary);
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          height: 35,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _adderExpanded = !_adderExpanded),
            icon: Icon(
              _adderExpanded ? Icons.expand_less : Icons.expand_more,
              color: kAccentLight,
              size: 30,
            ),
            label: Text(
              "Scheme Adder",
              style: TextStyle(color: kTextPrimary, fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: kBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: kAccent.withAlpha(100), width: 1.5),
            ),
          ),
        ),
        SizedBox(width: 10),
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _adderExpanded
              ? buildSection(
                  label: "",
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 175,
                        child: TextField(
                          maxLength: 24,
                          controller: nameController,
                          decoration: fieldDecoration(
                            "Scheme Name",
                          ).copyWith(counterText: ""),
                          style: TextStyle(color: kTextPrimary, fontSize: 14),
                        ),
                      ),
                    ), // name
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 20,
                      children: [
                        _colorTextField(
                          bgController,
                          "BackGround",
                          bgError == 0 ? kAccent : Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          surfaceController,
                          "Surface",
                          surfaceError == 0 ? kAccent : Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          accentController,
                          "Accent",
                          accentError == 0 ? kAccent : Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          accentLightController,
                          "Accent Light",
                          accentLightError == 0 ? kAccent : Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          textPrimaryController,
                          "Text Primary",
                          textPrimaryError == 0 ? kAccent : Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          textSecondaryController,
                          "Text Secondary",
                          textSecondaryError == 0 ? kAccent : Color(0xFFFF0000),
                        ),
                      ],
                    ), // colors
                    Align(
                      alignment: Alignment.centerRight,
                      child: Tooltip(
                        message: "Add Scheme",
                        decoration: BoxDecoration(
                          color: kSurfaceColor,
                          border: Border.all(width: 1, color: kAccent),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textStyle: TextStyle(color: kTextPrimary),
                        child: IconButton(
                          onPressed: () {
                            if (addTest() == 1) {
                              ref
                                  .read(toolsControllerProvider)
                                  .addOwnColorScheme(
                                    name: nameController.text,
                                    bg: parseHexColor(bgController.text)!,
                                    surface: parseHexColor(
                                      surfaceController.text,
                                    )!,
                                    accent: parseHexColor(
                                      accentController.text,
                                    )!,
                                    accentLight: parseHexColor(
                                      accentLightController.text,
                                    )!,
                                    textPrimary: parseHexColor(
                                      textPrimaryController.text,
                                    )!,
                                    textSecondary: parseHexColor(
                                      textSecondaryController.text,
                                    )!,
                                  );
                            }
                          },
                          icon: Icon(Icons.add, color: Colors.green),
                        ),
                      ),
                    ), // add button
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _colorTextField(
    TextEditingController controller,
    String label,
    Color mark,
  ) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: kBgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mark.withAlpha(100), width: 2),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              if (mark != kAccent)
                Tooltip(
                  message:
                      "Incomplete Hex Code (Must be 8 characters: AARRGGBB)",
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    border: Border.all(width: 2, color: mark.withAlpha(100)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  preferBelow: false,
                  verticalOffset: 18,
                  textStyle: TextStyle(color: kTextPrimary),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 15,
                    color: Colors.yellow,
                  ),
                ),
            ],
          ),
          SizedBox(height: 3),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(
                    int.tryParse(controller.text, radix: 16) ?? 0x00000000,
                  ),
                  border: Border.all(width: 2, color: Colors.white70),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 125,
                child: TextField(
                  maxLength: 8,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                  ],
                  controller: controller,
                  decoration: fieldDecoration(
                    "",
                  ).copyWith(prefixText: "0x ", counterText: ""),
                  style: TextStyle(color: kTextPrimary, fontSize: 14),
                  onChanged: (value) => _onColorChanged(label, value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
