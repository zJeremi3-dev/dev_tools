import 'dart:isolate';

import '../colors.dart';
import '../widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

BigInt _generatePrime() {
  final random = Random.secure();
  final numBytes = (1024 + 7) ~/ 8;

  while (true) {
    final bytes = Uint8List(numBytes);
    for (int i = 0; i < numBytes; i++) {
      bytes[i] = random.nextInt(256);
    }
    bytes[0] |= 0x80;
    bytes[numBytes - 1] |= 0x01;

    BigInt candidate = BigInt.zero;
    for (int byte in bytes) {
      candidate = (candidate << 8) | BigInt.from(byte);
    }

    if (candidate <= BigInt.one) continue;
    if (candidate.isEven && candidate != BigInt.two) continue;

    BigInt d = candidate - BigInt.one;
    int s = 0;
    while (d.isEven) {
      d >>= 1;
      s++;
    }

    bool isPrime = true;
    for (int i = 0; i < 40; i++) {
      BigInt range = candidate - BigInt.from(4);
      BigInt a;
      do {
        final aBytes = Uint8List(numBytes);
        for (int j = 0; j < numBytes; j++) {
          aBytes[j] = random.nextInt(256);
        }
        BigInt temp = BigInt.zero;
        for (int byte in aBytes) {
          temp = (temp << 8) | BigInt.from(byte);
        }
        a = BigInt.two + (temp % range);
      } while (a < BigInt.two || a >= candidate - BigInt.one);
      BigInt x = a.modPow(d, candidate);
      if (x == BigInt.one || x == candidate - BigInt.one) continue;

      bool composite = true;
      for (int r = 1; r < s; r++) {
        x = x.modPow(BigInt.two, candidate);
        if (x == candidate - BigInt.one) {
          composite = false;
          break;
        }
      }
      if (composite) {
        isPrime = false;
        break;
      }
    }
    if (isPrime) return candidate;
  }
}

class RSADialog extends StatefulWidget {
  const RSADialog({super.key});

  @override
  State<RSADialog> createState() => _RSADialogState();
}

class _RSADialogState extends State<RSADialog> {
  final _inputController = TextEditingController();
  final _publicController = TextEditingController();
  final _privateController = TextEditingController();
  int _mode = 0; // 0 = generator, 1 = tester
  String? _error;
  String? _encodedText;
  String? _decodedText;

  //mode 0
  String? publicKey;
  String? privateKey;

  Future<void> generator() async {
    try {
      final results = await Future.wait([
        Isolate.run(_generatePrime),
        Isolate.run(_generatePrime),
      ]);
      BigInt p = results[0];
      BigInt q = results[1];
      while (p == q) {
        q = await Isolate.run(_generatePrime);
      }

      BigInt n = p * q;
      BigInt phi = (p - BigInt.one) * (q - BigInt.one);

      BigInt e = BigInt.from(65537);
      while (e.gcd(phi) != BigInt.one) {
        e += BigInt.two;
      }

      BigInt d = e.modInverse(phi);
      if (!mounted) return;
      setState(() {
        publicKey = "$e, $n";
        privateKey = "$d, $n";
      });
    } catch (e) {
      return;
    }
  }

  void _recalculate() {
    setState(() => _error = null);
    try {
      tester(1);
      tester(2);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("FormatException: ", "");
      });
    }
  }

  void tester(int art) {
    //art: 1 = encrypting, 2 = decrypting
    if (art == 1) {
      if (_inputController.text.isEmpty) {
        setState(() => _encodedText = null);
        return;
      }
      if (_publicController.text.isEmpty) {
        setState(() => _encodedText = null);
        return;
      }

      final cipherList = _encrypt(
        _inputController.text,
        _publicController.text,
      );
      setState(() {
        _encodedText = cipherList.join(' ');
      });
    }
    if (art == 2) {
      if (_inputController.text.isEmpty) {
        setState(() => _decodedText = null);
        return;
      }
      if (_publicController.text.isEmpty) {
        setState(() => _decodedText = null);
        return;
      }
      if (_privateController.text.isEmpty) {
        setState(() => _decodedText = null);
        return;
      }

      final cipherText = _encodedText!
          .trim()
          .split(RegExp(r'\s+'))
          .map((e) => BigInt.parse(e))
          .toList();

      // Encrypting
      final resultText = _decrypt(cipherText, _privateController.text);
      setState(() {
        _decodedText = resultText;
      });
    }
  }

  List<BigInt> _encrypt(String text, String keyString) {
    final keyParts = _parseKey(keyString);
    final e = keyParts[0];
    final N = keyParts[1];

    final bytes = text.codeUnits;
    return bytes.map((byte) {
      final m = BigInt.from(byte);
      if (m >= N) {
        throw FormatException(
          "Modulus N is too small for the character '$byte'.",
        );
      }
      return m.modPow(e, N);
    }).toList();
  }

  String _decrypt(List<BigInt> cipherText, String keyString) {
    final keyParts = _parseKey(keyString);
    final d = keyParts[0];
    final N = keyParts[1];

    final decryptedBytes = cipherText.map((c) {
      return c.modPow(d, N).toInt();
    }).toList();

    return String.fromCharCodes(decryptedBytes);
  }

  static List<BigInt> _parseKey(String keyString) {
    final cleaned = keyString.replaceAll(',', '');
    final parts = cleaned.trim().split(RegExp(r'\s+'));

    if (parts.length != 2) {
      throw const FormatException(
        "Key must be in the format 'e, n' or 'd, n'.",
      );
    }
    final exp = BigInt.tryParse(parts[0]);
    final mod = BigInt.tryParse(parts[1]);

    if (exp == null || mod == null) {
      throw const FormatException("Invalid numbers in key.");
    }
    return [exp, mod];
  }

  @override
  void dispose() {
    _inputController.dispose();
    _publicController.dispose();
    _privateController.dispose();
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
                'RSA Key-Pair',
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
            labels: ["Generator", "Tester"],
            onChanged: (value) {
              setState(() => _mode = value);
            },
          ),
          const SizedBox(height: 16),

          // Output
          if (_mode == 0)
            Align(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: kBgColor,
                      borderRadius: BorderRadius.circular(17.5),
                      border: Border.all(color: kAccent.withAlpha(40)),
                    ),
                    child: IconButton(
                      onPressed: () {
                        generator();
                      },
                      icon: privateKey == null
                          ? Icon(Icons.play_arrow)
                          : Icon(Icons.refresh_rounded),
                      iconSize: 22,
                      color: kAccentLight,
                    ),
                  ), // Generate Button
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: kBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kAccent.withAlpha(40)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SelectableText(
                            _error ?? (publicKey ?? '—'),
                            style: TextStyle(
                              color: _error != null
                                  ? Colors.redAccent
                                  : kTextPrimary,
                              fontSize: 13,
                              letterSpacing: 0.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        buildCopyButton(
                          context: context,
                          copyText: publicKey ?? "",
                        ),
                      ],
                    ),
                  ), // Public Key
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: kBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kAccent.withAlpha(40)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SelectableText(
                            _error ?? (privateKey ?? '—'),
                            style: TextStyle(
                              color: _error != null
                                  ? Colors.redAccent
                                  : kTextPrimary,
                              fontSize: 13,
                              letterSpacing: 0.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        buildCopyButton(
                          context: context,
                          copyText: privateKey ?? "",
                        ),
                      ],
                    ),
                  ), // Private Key
                ],
              ),
            ),
          if (_mode == 1)
            Align(
              child: Column(
                children: [
                  buildSection(
                    label: 'Key-Pair Test',
                    children: [
                      TextField(
                        controller: _inputController,
                        autofocus: true,
                        maxLines: 4,
                        minLines: 1,
                        decoration: fieldDecoration('Text'),
                        style: TextStyle(color: kTextPrimary, fontSize: 14),
                        onChanged: (value) => _recalculate(),
                      ), // Text
                      Text(
                        'Enter the text to be encrypted',
                        style: TextStyle(color: kTextSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _publicController,
                        autofocus: false,
                        maxLines: 4,
                        minLines: 1,
                        decoration: fieldDecoration('Public Key (e, n)'),
                        style: TextStyle(color: kTextPrimary, fontSize: 14),
                        onChanged: (value) => _recalculate(),
                      ), // Public Key
                      Text(
                        'Enter your public key for encryption',
                        style: TextStyle(color: kTextSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: kBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kAccent.withAlpha(40)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: SelectableText(
                          _encodedText ?? '—',
                          style: TextStyle(
                            color: _error != null
                                ? Colors.redAccent
                                : kTextPrimary,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ), // Encrypted Text
                      const SizedBox(height: 6),
                      TextField(
                        controller: _privateController,
                        autofocus: false,
                        maxLines: 4,
                        minLines: 1,
                        decoration: fieldDecoration('Private Key (d, n)'),
                        style: TextStyle(color: kTextPrimary, fontSize: 14),
                        onChanged: (value) => _recalculate(),
                      ), // Private Key
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: kBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kAccent.withAlpha(40)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: SelectableText(
                          _decodedText ?? '—',
                          style: TextStyle(
                            color: _error != null
                                ? Colors.redAccent
                                : kTextPrimary,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ), // Decrypted Encrypted Text
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
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
