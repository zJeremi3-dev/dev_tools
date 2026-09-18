import '../colors.dart';
import '../widgets/widgets.dart';

import 'dart:convert';
import 'package:flutter/material.dart';

class JsonFormatDialog extends StatefulWidget {
  const JsonFormatDialog({super.key});

  @override
  State<JsonFormatDialog> createState() => _JsonFormatDialogState();
}

class _JsonFormatDialogState extends State<JsonFormatDialog> {
  final _inputController = TextEditingController();
  String _input = "";
  int _mode = 0; // 0 = format (pretty), 1 = minify
  String? _output;
  String? _error;

  void convert() {
    if (_input.trim().isEmpty) {
      setState(() {
        _output = null;
        _error = null;
      });
      return;
    }
    try {
      final decoded = jsonDecode(_input);
      if (_mode == 0) {
        setState(() {
          _output = const JsonEncoder.withIndent('  ').convert(decoded);
          _error = null;
        });
      } else {
        setState(() {
          _output = jsonEncode(decoded);
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _output = null;
        _error = 'Invalid JSON: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
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
                'JSON Formatter',
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
            labels: const ["Format", "Minify"],
            onChanged: (value) {
              if (_input.isEmpty || _output == null || _error != null) {
                setState(() => _mode = value);
                return;
              }
              setState(() {
                _mode = value;
                _input = _output!;
                _inputController.text = _output!;
              });
              convert();
            },
          ),
          const SizedBox(height: 16),

          // Input
          buildSection(
            label: 'JSON Input',
            children: [
              TextField(
                controller: _inputController,
                autofocus: true,
                maxLines: 6,
                minLines: 3,
                decoration: fieldDecoration(''),
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                onChanged: (value) {
                  setState(() => _input = value);
                  convert();
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Paste your JSON to format or minify it.',
                style: TextStyle(color: kTextSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Output
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: kBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAccent.withAlpha(40)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _error ?? (_output ?? '—'),
                      style: TextStyle(
                        color: _error != null ? Colors.redAccent : kTextPrimary,
                        fontSize: 13,
                        letterSpacing: 0.3,
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
