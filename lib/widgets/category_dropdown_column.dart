import '../colors.dart';
import 'package:flutter/material.dart';

class CategoryDropdownColumn extends StatefulWidget {
  final String category;
  final List<Widget> items;
  final bool initiallyExpanded;

  const CategoryDropdownColumn({
    super.key,
    required this.category,
    required this.items,
    this.initiallyExpanded = true,
  });

  @override
  State<CategoryDropdownColumn> createState() => _CategoryDropdownColumnState();
}

class _CategoryDropdownColumnState extends State<CategoryDropdownColumn> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kAccent.withAlpha(40)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.category,
                    style: TextStyle(
                      color: kAccentLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: kTextSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.items,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

Widget buildTabularToolRow({
  required IconData icon,
  required String name,
  required bool isFavorite,
  required VoidCallback onTap,
  required VoidCallback onToggleFavorite,
  required void Function(Offset position) onSecondaryTapDown,
}) {
  return GestureDetector(
    onSecondaryTapDown: (d) => onSecondaryTapDown(d.globalPosition),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon, color: kAccentLight, size: 20),
                  SizedBox(width: 10),
                  Text(
                    name,
                    style: TextStyle(color: kTextPrimary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggleFavorite,
              child: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                size: 18,
                color: isFavorite ? Colors.yellow : kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
