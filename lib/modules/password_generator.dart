import '../colors.dart';
import '../widgets/widgets.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordGenDialog extends StatefulWidget {
  const PasswordGenDialog({super.key});

  @override
  State<PasswordGenDialog> createState() => _PasswordGenDialogState();
}

class _PasswordGenDialogState extends State<PasswordGenDialog> {
  final lengthController = TextEditingController(text: '16');
  final numberController = TextEditingController();
  final symbolsController = TextEditingController();
  int _length = 16;
  int _minNum = 1;
  int _minSym = 0;
  bool _includeUpper = true;
  bool _includeLower = true;
  bool _includeDigits = true;
  bool _includeSymbols = false;
  String pw = "";
  final String _upperChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final String _lowerChars = "abcdefghijklmnopqrstuvwxyz";
  final String _digitChars = "0123456789";
  final String _symbolChars = "!@#\$%^&*";
  String _charPool = "";
  String _guaranteedChars = "";
  int chars = 0;
  int _get = 0;
  @override
  void dispose() {
    lengthController.dispose();
    numberController.dispose();
    symbolsController.dispose();
    super.dispose();
  }

  void generator() {
    setState(() {
      pw = "";
      _charPool = "";
      _guaranteedChars = "";
      _get = 0;
      chars = 0;
    });
    // _charPool & _guaranteedChars definition
    if (_includeUpper) {
      setState(() {
        _charPool += _upperChars;
        _guaranteedChars += _upperChars[Random().nextInt(_upperChars.length)];
        chars++;
      });
    }
    if (_includeLower) {
      setState(() {
        _charPool += _lowerChars;
        _guaranteedChars += _lowerChars[Random().nextInt(_lowerChars.length)];
        chars++;
      });
    }
    if (_includeDigits) {
      setState(() {
        _charPool += _digitChars;
        for (int i = 0; i < _minNum; i++) {
          _guaranteedChars += _digitChars[Random().nextInt(_digitChars.length)];
          chars++;
        }
      });
    }
    if (_includeSymbols) {
      setState(() {
        _charPool += _symbolChars;
        for (int i = 0; i < _minSym; i++) {
          _guaranteedChars +=
              _symbolChars[Random().nextInt(_symbolChars.length)];
          chars++;
        }
      });
    }

    if (int.tryParse(lengthController.text)! < chars) {
      setState(() {
        _length = chars;
        lengthController.text = "$chars";
      });
    }

    while (_get != (_length - chars)) {
      setState(() {
        pw += _charPool[Random().nextInt(_charPool.length)];
        _get++;
      });
    }
    setState(() {
      pw += _guaranteedChars;
      final list = pw.split('')..shuffle();
      pw = list.join();
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
                'Generator',
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

          // Password-Display
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
                    pw,
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
                      generator();
                    },
                    icon: pw == ""
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
                buildCopyButton(context: context, copyText: pw),
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

          // Length
          buildSection(
            label: 'Length',
            children: [
              TextField(
                controller: lengthController,
                autofocus: true,
                decoration: fieldDecoration(''),
                style: TextStyle(color: kTextPrimary, fontSize: 14),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) return newValue;
                    final val = int.tryParse(newValue.text);
                    if (val == null || val > 128) return oldValue;
                    return newValue;
                  }),
                ],
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    setState(() {
                      _length = parsed;
                      numberController.clear();
                      _includeDigits ? _minNum = 1 : _minNum = 0;
                      symbolsController.clear();
                      _includeSymbols ? _minSym = 1 : _minSym = 0;
                    });
                  }
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Please enter a value up to 128.',
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
                  buildCheckboxOption(
                    'A-Z',
                    _includeUpper,
                    () => setState(() => _includeUpper = !_includeUpper),
                  ),
                  buildCheckboxOption(
                    'a-z',
                    _includeLower,
                    () => setState(() => _includeLower = !_includeLower),
                  ),
                  buildCheckboxOption('0-9', _includeDigits, () {
                    setState(() {
                      _includeDigits ? _minNum = 0 : _minNum = 1;
                      _includeDigits = !_includeDigits;
                    });
                    numberController.clear();
                  }),
                  buildCheckboxOption('!@#\$%^&*', _includeSymbols, () {
                    setState(() {
                      _includeSymbols ? _minSym = 0 : _minSym = 1;
                      _includeSymbols = !_includeSymbols;
                    });
                    symbolsController.clear();
                  }),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: numberController,
                      decoration: fieldDecoration('Min. digits'),
                      style: TextStyle(color: kTextPrimary, fontSize: 14),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) return newValue;
                          final val = int.tryParse(newValue.text);
                          if (val == null ||
                              val >
                                  (_length -
                                      (_minSym +
                                          (_includeUpper ? 1 : 0) +
                                          (_includeLower ? 1 : 0)))) {
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null) setState(() => _minNum = parsed);
                        if (parsed == 0) {
                          setState(() {
                            _minNum = 0;
                            _includeDigits = false;
                          });
                        }
                        if (parsed != null && parsed > 0) {
                          setState(() => _includeDigits = true);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: symbolsController,
                      decoration: fieldDecoration('Min. special chars'),
                      style: TextStyle(color: kTextPrimary, fontSize: 14),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) return newValue;
                          final val = int.tryParse(newValue.text);
                          if (val == null ||
                              val >
                                  (_length -
                                      (_minNum +
                                          (_includeUpper ? 1 : 0) +
                                          (_includeLower ? 1 : 0)))) {
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null) {
                          setState(() => _minSym = parsed);
                        }
                        if (parsed == 0) {
                          setState(() {
                            _minSym = 0;
                            _includeSymbols = false;
                          });
                        }
                        if (parsed != null && parsed > 0) {
                          setState(() => _includeSymbols = true);
                        }
                      },
                    ),
                  ),
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
