import '../colors.dart';
import '../widgets/widgets.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PWStrengthDialog extends StatefulWidget {
  const PWStrengthDialog({super.key});

  @override
  State<PWStrengthDialog> createState() => _PWStrengthDialogState();
}

class _PWStrengthDialogState extends State<PWStrengthDialog> {
  final _pwController = TextEditingController();
  bool _includeUpper = true;
  bool _includeLower = true;
  bool _includeDigits = true;
  bool _includeSymbols = false;
  String pw = "";
  int room = 0;
  double _entropy = 0.0;
  String _strength = "";
  String _input = "";
  @override
  void initState() {
    super.initState();
    _pwController.addListener(inputCheck);
    inputCheck();
  }

  void inputCheck() {
    String input = "";
    if (_includeUpper) input += r"A-Z";
    if (_includeLower) input += r"a-z";
    if (_includeDigits) input += r"0-9";
    if (_includeSymbols) input += r"!@#\$%^&*";
    setState(() {
      _input = input;
    });
  }

  @override
  void dispose() {
    _pwController.dispose();
    super.dispose();
  }

  void test() {
    setState(() {
      room = 0;
    });
    if (_includeUpper) setState(() => room += 26);
    if (_includeLower) setState(() => room += 26);
    if (_includeDigits) setState(() => room += 10);
    if (_includeSymbols) setState(() => room += 8);
    setState(() => _entropy = pw.length * (log(room) / log(2)));
    if (_entropy < 28) {
      setState(() => _strength = "Very Weak");
    } else if (_entropy < 36) {
      setState(() => _strength = "Weak");
    } else if (_entropy < 60) {
      setState(() => _strength = "Fair");
    } else if (_entropy < 128) {
      setState(() => _strength = "Strong");
    } else {
      setState(() => _strength = "Very Strong");
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
                'Strength Tester',
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

          // Entropy-/Strength-Display
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
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Entropy: ${_entropy.toStringAsFixed(2)}  -> ",
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 15,
                            letterSpacing: 1,
                            fontFamily: 'monospace',
                          ),
                        ),
                        TextSpan(
                          text: _strength,
                          style: TextStyle(
                            color: () {
                              return _strength == "Very Weak"
                                  ? Color(0xFF81C784)
                                  : _strength == "Weak"
                                  ? Color(0xFFFFEE58)
                                  : _strength == "Fair"
                                  ? Color(0xFFFFA726)
                                  : _strength == "Strong"
                                  ? Color(0xFFe53935)
                                  : _strength == "Very Strong"
                                  ? Color(0xFF4A148C)
                                  : Color(0x00000000);
                            }(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Tooltip(
                  message: "Test",
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    border: Border.all(width: 1, color: kAccent),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  textStyle: TextStyle(color: kTextPrimary),
                  child: IconButton(
                    onPressed: () {
                      test();
                    },
                    icon: _strength == ""
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
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Options-Label
          Text(
            'Options',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          // Password Input
          buildSection(
            label: 'Password',
            children: [
              TextField(
                controller: _pwController,
                autofocus: true,
                decoration: fieldDecoration(''),
                style: TextStyle(color: kTextPrimary, fontSize: 14),
                inputFormatters: [
                  _input.isEmpty
                      ? FilteringTextInputFormatter.allow(RegExp(r'a^'))
                      : FilteringTextInputFormatter.allow(RegExp('[$_input]')),
                ],
                onChanged: (value) {
                  setState(() => pw = value);
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Password may contain A-Z, a-z, 0-9, !@#\$%^&*.',
                style: TextStyle(color: kTextSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Include
          buildSection(
            label: 'Include',
            children: [
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  buildCheckboxOption('A-Z', _includeUpper, () {
                    setState(() {
                      _includeUpper = !_includeUpper;
                    });
                    inputCheck();
                  }),
                  buildCheckboxOption('a-z', _includeLower, () {
                    setState(() {
                      _includeLower = !_includeLower;
                    });
                    inputCheck();
                  }),
                  buildCheckboxOption('0-9', _includeDigits, () {
                    setState(() {
                      _includeDigits = !_includeDigits;
                    });
                    inputCheck();
                  }),
                  buildCheckboxOption('!@#\$%^&*', _includeSymbols, () {
                    setState(() {
                      _includeSymbols = !_includeSymbols;
                    });
                    inputCheck();
                  }),
                ],
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
