import '../colors.dart';
import '../models/tool_module.dart';

import 'package:flutter/material.dart';

class HiddenModulesSection extends StatefulWidget {
  final List<ToolModule> visibleTools;
  final List<ToolModule> hiddenTools;
  final void Function(double id) onHide;
  final void Function(double id) onUnHide;

  const HiddenModulesSection({
    super.key,
    required this.visibleTools,
    required this.hiddenTools,
    required this.onHide,
    required this.onUnHide,
  });

  @override
  State<HiddenModulesSection> createState() => _HiddenModulesSectionState();
}

class _HiddenModulesSectionState extends State<HiddenModulesSection> {
  bool _hiddenModulesExpanded = false;
  final _hideDropdownKey = GlobalKey<FormFieldState<double>>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 200,
              height: 35,
              child: OutlinedButton.icon(
                onPressed: () => setState(
                  () => _hiddenModulesExpanded = !_hiddenModulesExpanded,
                ),
                icon: Icon(
                  _hiddenModulesExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: kAccentLight,
                  size: 30,
                ),
                label: Text(
                  "Hidden Modules",
                  style: TextStyle(color: kTextPrimary, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: kAccent.withAlpha(100), width: 1.5),
                ),
              ),
            ),
            SizedBox(width: 10),
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _hiddenModulesExpanded
                  ? SizedBox(
                      width: 200,
                      height: 35,
                      child: DropdownButtonFormField<double>(
                        key: _hideDropdownKey,
                        initialValue: null,
                        isExpanded: true,
                        isDense: true,
                        menuMaxHeight: 175,
                        icon: Icon(Icons.add, color: kTextSecondary, size: 18),
                        decoration: InputDecoration(
                          hintText: 'Hide Module',
                          hintStyle: TextStyle(
                            color: kTextSecondary,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: kBgColor,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: kAccent.withAlpha(50),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: kAccent.withAlpha(50),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: kAccent.withAlpha(50),
                            ),
                          ),
                        ),
                        dropdownColor: kSurfaceColor,
                        style: TextStyle(color: kTextPrimary, fontSize: 13),
                        items: widget.visibleTools
                            .map(
                              (t) => DropdownMenuItem<double>(
                                value: t.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      size: 20,
                                      color: kTextSecondary,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      t.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          if (id == null) return;
                          widget.onHide(id);
                          setState(() {
                            _hideDropdownKey.currentState?.reset();
                          });
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: 5),
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _hiddenModulesExpanded
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(),
                          child: SizedBox(
                            child: Icon(
                              Icons.subdirectory_arrow_right,
                              size: 30,
                              color: kAccentLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kAccent.withAlpha(100),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minHeight: 35,
                          maxHeight: 165,
                          minWidth: 200,
                        ),
                        child: widget.hiddenTools.isEmpty
                            ? Text(
                                "No hidden modules",
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.hiddenTools
                                      .map(
                                        (t) => Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                            left: 6,
                                          ),
                                          child: GestureDetector(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "",
                                                      style: TextStyle(
                                                        color: kTextPrimary,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .visibility_off_outlined,
                                                      size: 20,
                                                      color: kTextSecondary,
                                                    ),
                                                    Text(
                                                      " ${t.name}",
                                                      style: TextStyle(
                                                        color: kTextPrimary,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              widget.onUnHide(t.id);
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
