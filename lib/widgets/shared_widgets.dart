import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors.dart';

void showCopiedSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      content: _CopiedSnackbarContent(),
    ),
  );
}

Widget buildSection({required String label, required List<Widget> children}) {
  return Container(
    decoration: BoxDecoration(
      color: kBgColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kAccent.withAlpha(40), width: 1),
    ),
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != "")
          Text(
            label,
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        if (label != "") const SizedBox(height: 10),
        ...children,
      ],
    ),
  );
}

InputDecoration fieldDecoration(String label) => InputDecoration(
  labelText: label,
  labelStyle: TextStyle(color: kTextSecondary, fontSize: 12),
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: kAccent.withAlpha(60)),
  ),
  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: kAccent.withAlpha(60)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: kAccent),
  ),
  filled: true,
  fillColor: kSurfaceColor,
);
Widget buildCheckboxOption(String label, bool value, VoidCallback onTap) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 20,
        height: 20,
        child: Checkbox(value: value, onChanged: (_) => onTap()),
      ),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: kTextSecondary, fontSize: 12)),
    ],
  );
}

Widget buildSegmentedToggle({
  required int groupValue,
  required List<String> labels,
  required ValueChanged<int> onChanged,
}) {
  return SizedBox(
    width: double.infinity,
    child: CupertinoSlidingSegmentedControl<int>(
      groupValue: groupValue,
      backgroundColor: kBgColor,
      thumbColor: kAccent.withAlpha(60),
      padding: const EdgeInsets.all(4),
      children: {
        for (int i = 0; i < labels.length; i++)
          i: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              labels[i],
              style: TextStyle(
                color: groupValue == i ? kTextPrimary : kTextSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      },
      onValueChanged: (value) => onChanged(value!),
    ),
  );
}

Widget buildCopyButton({
  required BuildContext context,
  required String copyText,
}) {
  return Tooltip(
    message: "Copy",
    decoration: BoxDecoration(
      color: kSurfaceColor,
      border: Border.all(width: 1, color: kAccent),
      borderRadius: BorderRadius.circular(5),
    ),
    textStyle: TextStyle(color: kTextPrimary),
    child: IconButton(
      onPressed: copyText.isEmpty
          ? null
          : () {
              Clipboard.setData(ClipboardData(text: copyText));
              showCopiedSnackbar(context);
            },
      icon: const Icon(Icons.copy_rounded),
      color: kAccentLight,
      iconSize: 20,
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    ),
  );
}

class _CopiedSnackbarContent extends StatefulWidget {
  @override
  State<_CopiedSnackbarContent> createState() => _CopiedSnackbarContentState();
}

class _CopiedSnackbarContentState extends State<_CopiedSnackbarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Successfully Copied',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Icon(Icons.close, color: kTextSecondary, size: 18),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => LinearProgressIndicator(
              value: 1 - _controller.value,
              backgroundColor: Colors.transparent,
              color: const Color(0xFF4CAF50),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
