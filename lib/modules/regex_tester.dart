import '../colors.dart';
import '../widgets/widgets.dart';

import 'package:flutter/material.dart';

class RegexTesterDialog extends StatefulWidget {
  const RegexTesterDialog({super.key});

  @override
  State<RegexTesterDialog> createState() => _RegexTesterDialogState();
}

class _RegexTesterDialogState extends State<RegexTesterDialog> {
  final _patternController = TextEditingController();
  final _testController = TextEditingController();

  bool _ignoreCase = false;
  bool _multiLine = false;
  bool _dotAll = false;

  List<RegExpMatch> _matches = [];
  String? _error;

  void _test() {
    final pattern = _patternController.text;
    final input = _testController.text;
    if (pattern.isEmpty) {
      setState(() {
        _matches = [];
        _error = null;
      });
      return;
    }
    try {
      final regex = RegExp(
        pattern,
        caseSensitive: !_ignoreCase,
        multiLine: _multiLine,
        dotAll: _dotAll,
      );
      setState(() {
        _matches = regex.allMatches(input).toList();
        _error = null;
      });
    } catch (e) {
      setState(() {
        _matches = [];
        _error = 'Invalid regex: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _patternController.dispose();
    _testController.dispose();
    super.dispose();
  }

  List<TextSpan> _buildHighlighted() {
    final input = _testController.text;
    if (_matches.isEmpty || input.isEmpty) {
      return [
        TextSpan(
          text: input.isEmpty ? '—' : input,
          style: TextStyle(color: kTextPrimary),
        ),
      ];
    }
    final spans = <TextSpan>[];
    int last = 0;
    for (final m in _matches) {
      if (m.start > last) {
        spans.add(
          TextSpan(
            text: input.substring(last, m.start),
            style: TextStyle(color: kTextPrimary),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: input.substring(m.start, m.end),
          style: TextStyle(
            color: kBgColor,
            backgroundColor: kAccentLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      last = m.end;
    }
    if (last < input.length) {
      spans.add(
        TextSpan(
          text: input.substring(last),
          style: TextStyle(color: kTextPrimary),
        ),
      );
    }
    return spans;
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
                'Regex Tester',
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

          // Pattern
          buildSection(
            label: 'Pattern (Regex)',
            children: [
              TextField(
                controller: _patternController,
                autofocus: true,
                decoration: fieldDecoration('z. B. ^[A-Za-z0-9]+\$'),
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                onChanged: (_) => _test(),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  buildCheckboxOption('Ignore case', _ignoreCase, () {
                    setState(() => _ignoreCase = !_ignoreCase);
                    _test();
                  }),
                  buildCheckboxOption('Multiline', _multiLine, () {
                    setState(() => _multiLine = !_multiLine);
                    _test();
                  }),
                  buildCheckboxOption('Dot matches all', _dotAll, () {
                    setState(() => _dotAll = !_dotAll);
                    _test();
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Test string
          buildSection(
            label: 'Test-String',
            children: [
              TextField(
                controller: _testController,
                maxLines: 5,
                minLines: 3,
                decoration: fieldDecoration(''),
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                onChanged: (_) => _test(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Output
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: kBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAccent.withAlpha(40)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: SingleChildScrollView(
              child: _error != null
                  ? Text(
                      _error!,
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    )
                  : RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13, fontFamily: 'monospace'),
                        children: _buildHighlighted(),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error != null ? ' ' : '${_matches.length} matches',
            style: TextStyle(color: kTextSecondary, fontSize: 11),
          ),
          const SizedBox(height: 14),

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
