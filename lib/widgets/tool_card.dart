import '../colors.dart';
import '../models/tool_module.dart';
import 'package:flutter/material.dart';

class ToolCard extends StatelessWidget {
  final ToolModule module;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final void Function(Offset position) onSecondaryTapDown;
  const ToolCard({
    super.key,
    required this.module,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onSecondaryTapDown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onSecondaryTapDown: (details) =>
            onSecondaryTapDown(details.globalPosition),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showDialog(
            context: context,
            builder: module.dialogBuilder,
            useRootNavigator: true,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 20),
                child: Row(
                  children: [
                    Icon(module.icon, color: kAccentLight, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.name,
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            module.description,
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: kTextSecondary, size: 20),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggleFavorite,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 20,
                      color: isFavorite ? Colors.yellow : kTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
