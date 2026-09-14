import '../colors.dart';
import '../widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BinDecConverterDialog extends StatefulWidget {
  const BinDecConverterDialog({super.key});

  @override
  State<BinDecConverterDialog> createState() => _BinDecConverterDialogState();
}

class _BinDecConverterDialogState extends State<BinDecConverterDialog> {
  final _inputController = TextEditingController();
  String? _input;
  String? _output;
  int _mode = 0;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void convert() {
    if (_input == null || _input!.isEmpty) {
      setState(() => _output = null);
      return;
    }
    try {
      _mode == 0
          ? setState(() => _output = BigInt.parse(_input!).toRadixString(2))
          : setState(
              () => _output = BigInt.parse(_input!, radix: 2).toString(),
            );
    } catch (_) {
      setState(() => _output = null);
    }
  }

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
                'Binary ↔ Decimal',
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

          // Mode
          buildSegmentedToggle(
            groupValue: _mode,
            labels: ["Decimal to Binary", "Binary to Decimal"],
            onChanged: (value) {
              setState(() {
                final oldInput = _input;
                _mode = value;
                _input = _output;
                _inputController.text = _output ?? '';
                _output = oldInput;
              });
            },
          ),
          const SizedBox(height: 16),

          // Output
          Container(
            decoration: BoxDecoration(
              color: kBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAccent.withAlpha(40)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _mode == 0
                          ? "Binary: ${_output ?? ''}"
                          : "Decimal: ${_output ?? ''}",
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 15,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                buildCopyButton(context: context, copyText: _output ?? ""),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Input
          buildSection(
            label: 'Input',
            children: [
              TextField(
                controller: _inputController,
                autofocus: true,
                decoration: fieldDecoration(_mode == 0 ? 'Decimal' : 'Binary'),
                style: TextStyle(color: kTextPrimary, fontSize: 14),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  _mode == 0
                      ? FilteringTextInputFormatter.digitsOnly
                      : FilteringTextInputFormatter.allow(RegExp('[01]')),
                ],
                onChanged: (value) {
                  setState(() => _input = value);
                  convert();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

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
