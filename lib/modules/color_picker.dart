import '../colors.dart';
import '../widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color _color = kAccent;
  String get _hex =>
      '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Color Picker',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: kTextSecondary, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Picker
          buildSection(
            label: "",
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColorPicker(
                  color: _color,
                  onChanged: (value) => setState(() => _color = value),
                  initialPicker: Picker.paletteHue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hex-Display + Copy
          Container(
            decoration: BoxDecoration(
              color: kBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAccent.withAlpha(40)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kAccent.withAlpha(60)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _hex,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 15,
                      letterSpacing: 1,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                buildCopyButton(context: context, copyText: _hex),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Close Button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: kAccent.withAlpha(30),
                foregroundColor: kAccentLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
