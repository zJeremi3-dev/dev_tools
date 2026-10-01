import '../../colors.dart';
import '../../own_colors.dart';
import '../../widgets/widgets.dart';
import '../../state/providers.dart';
import 'scheme_adder.dart';
import 'modify_ownscheme_dialog.dart';

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ColorSchemeDialog extends ConsumerWidget {
  const ColorSchemeDialog({super.key});

  Widget _colorButton(WidgetRef ref, ColorSchemeData scheme, int selected) {
    return Tooltip(
      message: scheme.name,
      decoration: BoxDecoration(
        color: kSurfaceColor,
        border: Border.all(width: 1, color: kAccent),
        borderRadius: BorderRadius.circular(5),
      ),
      textStyle: TextStyle(color: kTextPrimary),
      child: GestureDetector(
        onTap: () =>
            ref.read(toolsControllerProvider).setColorScheme(scheme.id),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.accent,
            border: Border.all(width: 2, color: Colors.white70),
            borderRadius: BorderRadius.circular(13),
          ),
          child: selected == scheme.id
              ? const Icon(Icons.check_box)
              : const Text(""),
        ),
      ),
    );
  }

  Widget _colorButtonOwn(
    WidgetRef ref,
    OwnColorSchemeData scheme,
    int selected,
  ) {
    double size = 25;
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: isHovered ? 60.0 : 0.0,
                  height: 40.0,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: kBgColor,
                    border: Border.all(
                      width: isHovered ? 2 : 0,
                      color: Colors.white70,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierColor: Colors.black.withAlpha(26),
                        builder: (context) =>
                            ModifyOwnSchemeDialog(schemeId: scheme.id),
                        useRootNavigator: true,
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 7.5),
                        child: Container(
                          color: kBgColor,
                          width: size,
                          height: size,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
                                child: Transform.rotate(
                                  angle: -math.pi / 4,
                                  child: Container(
                                    width: size * 1.1,
                                    height: 2,
                                    color: kTextSecondary,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Icon(
                                  Icons.drive_file_rename_outline_outlined,
                                  size: size * 0.45,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(
                                  Icons.delete_forever,
                                  size: size * 0.45,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: scheme.name,
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  border: Border.all(width: 1, color: kAccent),
                  borderRadius: BorderRadius.circular(5),
                ),
                textStyle: TextStyle(color: kTextPrimary),
                child: GestureDetector(
                  onTap: () => ref
                      .read(toolsControllerProvider)
                      .setOwnColorScheme(scheme.id),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.accent,
                      border: Border.all(width: 2, color: Colors.white70),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: selected == scheme.id
                        ? const Icon(Icons.check_box)
                        : const Text(""),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(toolsControllerProvider);

    return ResponsiveDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Color Scheme',
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
          buildSection(
            label: "Schemes",
            children: [
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: kColorSchemes
                    .map((s) => _colorButton(ref, s, selectedScheme))
                    .toList(),
              ),
            ],
          ),
          controller.ownColorSchemes.isNotEmpty
              ? buildSection(
                  label: "Own Schemes",
                  children: [
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: controller.ownColorSchemes
                          .map(
                            (s) => _colorButtonOwn(ref, s, selectedOwnScheme),
                          )
                          .toList(),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 8),
          SchemeAdderSection(),
          const SizedBox(height: 16),
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
