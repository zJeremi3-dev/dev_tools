import 'package:flutter/material.dart';

/// Immutable definition of a single tool shown in the app.
///
/// Purely a data holder — no logic, no state. The [dialogBuilder] is the
/// only piece of UI knowledge this class carries, kept as a builder
/// function so the dialog is only constructed when actually opened.
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
