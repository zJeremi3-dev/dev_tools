import '../colors.dart';
import '../widgets/widgets.dart';
import '../state/providers.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(toolsControllerProvider);
    final selected = selectedScheme;

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
            label: "Options",
            children: [
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: kColorSchemes
                    .map((s) => _colorButton(ref, s, selected))
                    .toList(),
              ),
            ],
          ),
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
