import '../colors.dart';
import '../widgets/widgets.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UuidGenDialog extends StatefulWidget {
  const UuidGenDialog({super.key});

  @override
  State<UuidGenDialog> createState() => _UuidGenDialogState();
}

class _UuidGenDialogState extends State<UuidGenDialog> {
  final _countController = TextEditingController(text: '5');
  int _count = 5;
  bool _uppercase = false;
  bool _hyphens = true;
  List<String> _uuids = [];

  String _generateUuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // Variant 10
    String hex(int start, int end) => bytes
        .sublist(start, end)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final sep = _hyphens ? '-' : '';
    final uuid =
        '${hex(0, 4)}$sep${hex(4, 6)}$sep${hex(6, 8)}$sep${hex(8, 10)}$sep${hex(10, 16)}';
    return _uppercase ? uuid.toUpperCase() : uuid;
  }

  void _generate() {
    final n = _count.clamp(1, 50);
    setState(() => _uuids = List.generate(n, (_) => _generateUuidV4()));
  }

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void dispose() {
    _countController.dispose();
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
                'UUID Generator',
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

          // Options
          buildSection(
            label: 'Options',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _countController,
                      decoration: fieldDecoration('Count'),
                      style: TextStyle(color: kTextPrimary, fontSize: 14),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        final n = int.tryParse(value);
                        if (n != null) setState(() => _count = n.clamp(1, 50));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Tooltip(
                    message: "Generate",
                    decoration: BoxDecoration(
                      color: kSurfaceColor,
                      border: Border.all(width: 1, color: kAccent),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: TextStyle(color: kTextPrimary),
                    child: IconButton(
                      onPressed: _generate,
                      icon: const Icon(Icons.refresh_rounded),
                      color: kAccentLight,
                      iconSize: 22,
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: [
                  buildCheckboxOption('Uppercase', _uppercase, () {
                    setState(() => _uppercase = !_uppercase);
                    _generate();
                  }),
                  buildCheckboxOption('Hyphens', _hyphens, () {
                    setState(() => _hyphens = !_hyphens);
                    _generate();
                  }),
                ],
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                children: _uuids
                    .map(
                      (u) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                u,
                                style: TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Tooltip(
                              message: "Copy",
                              decoration: BoxDecoration(
                                color: kSurfaceColor,
                                border: Border.all(width: 1, color: kAccent),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              textStyle: TextStyle(color: kTextPrimary),
                              child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: u));
                                  showCopiedSnackbar(context);
                                },
                                icon: const Icon(Icons.copy_rounded),
                                color: kAccentLight,
                                iconSize: 16,
                                constraints: const BoxConstraints(
                                  minWidth: 26,
                                  minHeight: 26,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _uuids.isEmpty
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: _uuids.join('\n')));
                      showCopiedSnackbar(context);
                    },
              icon: Icon(Icons.copy_all_rounded, size: 16, color: kAccentLight),
              label: Text(
                'Copy all',
                style: TextStyle(color: kAccentLight, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

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
