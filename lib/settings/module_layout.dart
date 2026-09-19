import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../colors.dart';

class ModuleLayoutSection extends StatefulWidget {
  final int initialValue;
  final void Function(int type)? onChanged;
  const ModuleLayoutSection({
    super.key,
    required this.initialValue,
    this.onChanged,
  });

  @override
  State<ModuleLayoutSection> createState() => _ModuleLayoutSectionState();
}

class _ModuleLayoutSectionState extends State<ModuleLayoutSection> {
  late bool custom = widget.initialValue == 1;
  late bool tabular = widget.initialValue == 3;

  void save() {
    int type;
    if (custom) {
      type = 1;
    } else if (tabular) {
      type = 3;
    } else {
      type = 2;
    }
    widget.onChanged?.call(type);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Module Layout",
          style: TextStyle(
            color: kTextSecondary,
            fontSize: 15,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCheckboxOption("Custom", custom, () {
              setState(() {
                custom = !custom;
                if (custom) tabular = false;
              });
              save();
            }),
            SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCheckboxOption("Category", !custom && !tabular, () {
                  setState(() {
                    custom = !custom;
                    if (custom) tabular = false;
                  });
                  save();
                }),
                SizedBox(height: 4),
                buildCheckboxOption("Tabular", tabular, () {
                  setState(() {
                    if (custom) custom = !custom;
                    tabular = !tabular;
                  });
                  save();
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
