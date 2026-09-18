import '../colors.dart';
import '../widgets/widgets.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RandomNumberDialog extends StatefulWidget {
  const RandomNumberDialog({super.key});

  @override
  State<RandomNumberDialog> createState() => _RandomNumberDialogState();
}

class _RandomNumberDialogState extends State<RandomNumberDialog> {
  final _fromInputController = TextEditingController();
  final _toInputController = TextEditingController();
  int? _fromInput = 1;
  int? _toInput = 100;
  int? _output;

  @override
  void initState() {
    setState(() {
      _fromInputController.text = _fromInput.toString();
      _toInputController.text = _toInput.toString();
    });
    randomizer();
    super.initState();
  }

  @override
  void dispose() {
    _fromInputController.dispose();
    _toInputController.dispose();
    super.dispose();
  }

  void randomizer() {
    if (_fromInput == null) return;
    if (_toInput == null) return;
    if (_toInput! < _fromInput!) {
      int x = 0;
      setState(() {
        x = _fromInput!;
        _fromInput = _toInput;
        _toInput = x;
        _fromInputController.text = _fromInput.toString();
        _toInputController.text = _toInput.toString();
      });
    }
    setState(() {
      _output = _fromInput! + Random().nextInt(_toInput! - _fromInput! + 1);
    });
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
                'Randomizer',
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
                  child: Text(
                    "Result: $_output",
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 15,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Tooltip(
                  message: "Generate",
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    border: Border.all(width: 1, color: kAccent),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  textStyle: TextStyle(color: kTextPrimary),
                  child: IconButton(
                    onPressed: () {
                      randomizer();
                    },
                    icon: _output == null
                        ? Icon(Icons.play_arrow)
                        : Icon(Icons.refresh_rounded),
                    color: kAccentLight,
                    iconSize: 22,
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 12),
                buildCopyButton(context: context, copyText: _output.toString()),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Input
          buildSection(
            label: 'Input',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fromInputController,
                      autofocus: true,
                      decoration: fieldDecoration('From'),
                      style: TextStyle(color: kTextPrimary, fontSize: 14),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() => _fromInput = int.tryParse(value));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _toInputController,
                      autofocus: false,
                      decoration: fieldDecoration('To'),
                      style: TextStyle(color: kTextPrimary, fontSize: 14),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() => _toInput = int.tryParse(value));
                      },
                    ),
                  ),
                ],
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
