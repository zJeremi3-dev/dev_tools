import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../colors.dart';
import '../../state/providers.dart';
import 'package:dev_tools/widgets/shared_widgets.dart';

import 'color_picker_overlay.dart';
import 'scheme_adder_controller.dart';

class SchemeAdderSection extends ConsumerStatefulWidget {
  const SchemeAdderSection({super.key});

  @override
  ConsumerState<SchemeAdderSection> createState() => _SchemeAdderSectionState();
}

class _SchemeAdderSectionState extends ConsumerState<SchemeAdderSection> {
  bool _adderExpanded = false;
  late final SchemeAdderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SchemeAdderController(ref);
  }

  @override
  void dispose() {
    ColorPickerOverlay.hide();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(toolsControllerProvider, (previous, next) {
      _controller.updateControllersFromGlobals();
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
                          controller: _controller.nameController,
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
                          _controller.bgController,
                          "BackGround",
                          _controller.bgError == 0
                              ? kAccent
                              : const Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          _controller.surfaceController,
                          "Surface",
                          _controller.surfaceError == 0
                              ? kAccent
                              : const Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          _controller.accentController,
                          "Accent",
                          _controller.accentError == 0
                              ? kAccent
                              : const Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          _controller.accentLightController,
                          "Accent Light",
                          _controller.accentLightError == 0
                              ? kAccent
                              : const Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          _controller.textPrimaryController,
                          "Text Primary",
                          _controller.textPrimaryError == 0
                              ? kAccent
                              : const Color(0xFFFF0000),
                        ),
                        _colorTextField(
                          _controller.textSecondaryController,
                          "Text Secondary",
                          _controller.textSecondaryError == 0
                              ? kAccent
                              : const Color(0xFFFF0000),
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
                            _controller.validateAndAddScheme(
                              () => setState(() {}),
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.green),
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
    final key = GlobalKey();
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
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 15,
                    color: Colors.yellow,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              GestureDetector(
                key: key,
                onTap: () => ColorPickerOverlay.show(
                  context: context,
                  key: key,
                  controller: controller,
                  label: label,
                  onColorChanged: (label, hex) => _controller.onColorChanged(
                    label,
                    hex,
                    () => setState(() {}),
                  ),
                ),
                child: Container(
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
              ),
              const SizedBox(width: 8),
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
                  onChanged: (value) => _controller.onColorChanged(
                    label,
                    value,
                    () => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
