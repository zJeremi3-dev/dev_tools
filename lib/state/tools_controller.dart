import 'package:dev_tools/colors.dart';
import 'package:flutter/material.dart';
import '../models/tool_module.dart';
import '../data/tools_repository.dart';
import '../data/daten_manager.dart';

/// Holds all mutable app state (favorites, ordering, hidden tools, layout,
/// color scheme) and the logic to change it.
///
/// Deliberately Flutter-agnostic beyond [ChangeNotifier] — this is what
/// makes it directly unit-testable without a widget tree. UI code should
/// only read from and call methods on this class, never touch
/// [DatenManager] directly.
class ToolsController extends ChangeNotifier {
  final List<ToolModule> tools = List.of(kTools);
  final List<String> categories = kCategories;

  List<double> favoriteOrder = [];
  List<double> normalOrder = [];
  List<double> hideOrder = [];
  int moduleLayout = 1;

  String searchQuery = "";
  int? selectedCategory;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  List<ToolModule> get filteredTools {
    var list = tools;
    if (hideOrder.isNotEmpty) {
      list = list.where((t) => !hideOrder.contains(t.id)).toList();
    }
    if (selectedCategory != null) {
      list = list
          .where((t) => t.category == categories[selectedCategory!])
          .toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where(
            (t) =>
                t.name.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  List<ToolModule> get favoriteTools {
    final orderMap = {
      for (var i = 0; i < favoriteOrder.length; i++) favoriteOrder[i]: i,
    };
    return filteredTools.where((t) => favoriteOrder.contains(t.id)).toList()
      ..sort((a, b) => orderMap[a.id]!.compareTo(orderMap[b.id]!));
  }

  List<ToolModule> get nonFavoriteTools =>
      filteredTools.where((t) => !favoriteOrder.contains(t.id)).toList();

  // --- Load ---
  /// Loads all persisted state from disk. Call once, typically via the
  /// `initialLoadProvider` FutureProvider at app start.
  Future<void> load() async {
    normalOrder = await DatenManager.loadNormalOrder();
    favoriteOrder = await DatenManager.loadFavoriteOrder();
    hideOrder = await DatenManager.loadHideOrder();
    moduleLayout = await DatenManager.loadModuleLayout();
    applyColorScheme(await DatenManager.loadColorScheme());
    _sortTools();
    notifyListeners();
  }

  // --- Search & Filter ---
  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setSelectedCategory(int? c) {
    selectedCategory = c;
    notifyListeners();
  }

  // --- Favorites ---
  /// Adds or removes [id] from the favorites, persists the change, and
  /// notifies listeners.
  void toggleFavorite(double id) {
    favoriteOrder.contains(id)
        ? favoriteOrder.remove(id)
        : favoriteOrder.add(id);
    DatenManager.saveFavoriteOrder(favoriteOrder);
    notifyListeners();
  }

  // --- Hide/Un-Hide ---
  /// Hides the tool with [id] from the main view (still visible in Settings).
  void hideModule(double id) {
    hideOrder.add(id);
    DatenManager.saveHideOrder(hideOrder);
    notifyListeners();
  }

  /// Reveals a previously hidden tool again.
  void unhideModule(double id) {
    hideOrder.remove(id);
    DatenManager.saveHideOrder(hideOrder);
    notifyListeners();
  }

  void toggleHide(double id) =>
      hideOrder.contains(id) ? unhideModule(id) : hideModule(id);

  // --- Module Layout ---
  /// Switches between layout mode 1 (custom grid), 2 (per-category grid),
  /// and 3 (tabular/dropdown), persisting the choice.
  void setModuleLayout(int type) {
    moduleLayout = type;
    DatenManager.saveModuleLayout(type);
    notifyListeners();
  }

  /// Applies and persists color scheme [id]. No-op if [id] is already active.
  void setColorScheme(int id) {
    if (selectedScheme == id) return;
    applyColorScheme(id);
    DatenManager.saveColorScheme(id);
    notifyListeners();
  }

  // --- Sorting ---
  void _sortTools() {
    if (normalOrder.isEmpty) return;
    tools.sort((a, b) {
      final indexA = normalOrder.indexOf(a.id);
      final indexB = normalOrder.indexOf(b.id);
      final safeA = indexA == -1 ? normalOrder.length : indexA;
      final safeB = indexB == -1 ? normalOrder.length : indexB;
      return safeA.compareTo(safeB);
    });
  }

  /// Reorders the non-favorited tools globally, moving the item at
  /// [oldIndex] to [newIndex]. Favorited tools are untouched.
  void reorder(int oldIndex, int newIndex) {
    final positions = <int>[];
    for (int i = 0; i < tools.length; i++) {
      if (!favoriteOrder.contains(tools[i].id)) positions.add(i);
    }
    final visible = positions.map((i) => tools[i]).toList();
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);
    for (int i = 0; i < positions.length; i++) {
      tools[positions[i]] = visible[i];
    }
    normalOrder = tools.map((t) => t.id).toList();
    DatenManager.saveNormalOrder(normalOrder);
    notifyListeners();
  }

  /// Like [reorder], but scoped to tools within a single [category].
  /// Tools outside that category keep their relative order.
  void reorderCategory(String category, int oldIndex, int newIndex) {
    final positions = <int>[];
    for (int i = 0; i < tools.length; i++) {
      if (tools[i].category == category &&
          !favoriteOrder.contains(tools[i].id)) {
        positions.add(i);
      }
    }
    final visible = positions.map((i) => tools[i]).toList();
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);
    for (int i = 0; i < positions.length; i++) {
      tools[positions[i]] = visible[i];
    }
    normalOrder = tools.map((t) => t.id).toList();
    DatenManager.saveNormalOrder(normalOrder);
    notifyListeners();
  }

  /// Reorders the favorites list itself.
  void reorderFavorites(int oldIndex, int newIndex) {
    final visible = favoriteTools;
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);
    favoriteOrder = visible.map((t) => t.id).toList();
    DatenManager.saveFavoriteOrder(favoriteOrder);
    notifyListeners();
  }
}
