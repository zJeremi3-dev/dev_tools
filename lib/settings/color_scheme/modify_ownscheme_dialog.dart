import '../../colors.dart';
import '../../widgets/widgets.dart';
import '../../state/providers.dart';
import 'color_scheme_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModifyOwnSchemeDialog extends ConsumerStatefulWidget {
  final int schemeId;

  const ModifyOwnSchemeDialog({super.key, required this.schemeId});

  @override
  ConsumerState<ModifyOwnSchemeDialog> createState() =>
      _ModifyOwnSchemeDialogState();
}

class _ModifyOwnSchemeDialogState extends ConsumerState<ModifyOwnSchemeDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(toolsControllerProvider);

    final scheme = controller.ownColorSchemes
        .where((s) => s.id == widget.schemeId)
        .firstOrNull;

    if (scheme == null) {
      return const SizedBox.shrink();
    }

    String schemeName = scheme.name;
    return ResponsiveDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Modify $schemeName',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: kTextSecondary, size: 20),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withAlpha(26),
                    builder: (context) => const ColorSchemeDialog(),
                    useRootNavigator: true,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildSection(
            label: "Rename",
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      decoration: fieldDecoration('now: $schemeName'),
                      style: TextStyle(color: kTextPrimary, fontSize: 14),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ref
                            .read(toolsControllerProvider)
                            .changeOwnColorSchemeName(
                              widget.schemeId,
                              _nameController.text,
                            );
                      },
                      icon: Icon(
                        Icons.drive_file_rename_outline_outlined,
                        size: 18,
                        color: kTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 45,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.red,
                border: Border.all(width: 3, color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withAlpha(26),
                    builder: (context) => const ColorSchemeDialog(),
                    useRootNavigator: true,
                  );
                  ref
                      .read(toolsControllerProvider)
                      .removeOwnColorScheme(widget.schemeId);
                },
                icon: Icon(Icons.delete_forever, size: 18, color: kTextPrimary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withAlpha(26),
                  builder: (context) => const ColorSchemeDialog(),
                  useRootNavigator: true,
                );
              },
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
