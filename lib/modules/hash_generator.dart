import '../colors.dart';
import '../widgets/widgets.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

class HashGenDialog extends StatefulWidget {
  const HashGenDialog({super.key});

  @override
  State<HashGenDialog> createState() => _HashGenDialogState();
}

class _HashGenDialogState extends State<HashGenDialog> {
  final _inputController = TextEditingController();
  String _text = "";
  String _selectedAlgo = "SHA-256";

  static const List<String> _algos = ["MD5", "SHA-1", "SHA-256", "SHA-512"];

  String get _hash {
    if (_text.isEmpty) return "";
    final bytes = utf8.encode(_text);
    switch (_selectedAlgo) {
      case "MD5":
        return md5.convert(bytes).toString();
      case "SHA-1":
        return sha1.convert(bytes).toString();
      case "SHA-256":
        return sha256.convert(bytes).toString();
      case "SHA-512":
        return sha512.convert(bytes).toString();
      default:
        return "";
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
                'Hash Generator',
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

          // Hash-Display
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
                    _hash.isEmpty ? '—' : _hash,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 13,
                      letterSpacing: 0.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                buildCopyButton(context: context, copyText: _hash),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Algorithm-Selection
          buildSection(
            label: 'Algorithm',
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedAlgo,
                decoration: fieldDecoration('Hash-Algorithm'),
                dropdownColor: kSurfaceColor,
                style: TextStyle(color: kTextPrimary, fontSize: 13),
                items: _algos
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedAlgo = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Text Input
          buildSection(
            label: 'Text',
            children: [
              TextField(
                controller: _inputController,
                autofocus: true,
                maxLines: 4,
                minLines: 1,
                decoration: fieldDecoration(''),
                style: TextStyle(color: kTextPrimary, fontSize: 14),
                onChanged: (value) => setState(() => _text = value),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the text to be hashed.',
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
