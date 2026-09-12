import 'package:flutter/material.dart';

class ToolModule {
  final double id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final Widget Function(BuildContext) dialogBuilder;

  const ToolModule({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.dialogBuilder,
  });
}