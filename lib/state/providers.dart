import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tools_controller.dart';

final toolsControllerProvider = ChangeNotifierProvider<ToolsController>((ref) {
  return ToolsController();
});
final initialLoadProvider = FutureProvider<void>((ref) async {
  await ref.read(toolsControllerProvider).load();
});