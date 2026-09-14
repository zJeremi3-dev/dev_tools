import '../colors.dart';
import 'package:flutter/material.dart';

class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveDialog({super.key, required this.child, this.maxWidth = 480});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final width = screen.width < maxWidth + 32 ? screen.width * 0.92 : maxWidth;
    final height = screen.height * 0.85;

    return Dialog(
      backgroundColor: kSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: height),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
