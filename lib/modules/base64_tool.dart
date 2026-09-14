import '../colors.dart';
import '../widgets/widgets.dart';

import 'dart:convert';
import 'package:flutter/material.dart';

class Base64Dialog extends StatefulWidget {
  const Base64Dialog({super.key});

  @override
  State<Base64Dialog> createState() => _Base64DialogState();
}

class _Base64DialogState extends State<Base64Dialog> {
  final _inputController = TextEditingController();
  String _input = "";
  int _mode = 0; // 0 = encode, 1 = decode
  String? _output;
  String? _error;

  void convert() {
    if (_input.isEmpty) {
      setState(() {
        _output = null;
        _error = null;
      });
      return;
    }
    try {
      if (_mode == 0) {
        setState(() {
          _output = base64.encode(utf8.encode(_input));
          _error = null;
        });
      } else {
        setState(() {
          _output = utf8.decode(base64.decode(_input));
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _output = null;
        _error = 'Invalid input: not valid Base64.';
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
                'Base64',
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
            labels: ["Encode", "Decode"],
            onChanged: (value) {
              setState(() => _mode = value);
              if (_input.isEmpty || _output == null) return;
              final previousInput = _input;
              setState(() {
                _input = _output!;
                _inputController.text = _output!;
                _output = previousInput;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    _error ?? (_output ?? '—'),
                    style: TextStyle(
                      color: _error != null ? Colors.redAccent : kTextPrimary,
                      fontSize: 13,
                      letterSpacing: 0.5,
                      fontFamily: 'monospace',
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
            label: _mode == 0 ? 'Text' : 'Base64',
            children: [
              TextField(
                controller: _inputController,
                autofocus: true,
                maxLines: 4,
                minLines: 1,
                decoration: fieldDecoration(''),
                style: TextStyle(color: kTextPrimary, fontSize: 14),
                onChanged: (value) {
                  setState(() => _input = value);
                  convert();
                },
              ),
              const SizedBox(height: 6),
              Text(
                _mode == 0
                    ? 'Enter the text to encode.'
                    : 'Enter the Base64 string to decode.',
                style: TextStyle(color: kTextSecondary, fontSize: 11),
              ),
            ],
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
