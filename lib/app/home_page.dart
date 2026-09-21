import 'dart:io';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/providers.dart';
import '../colors.dart';
import '../models/tool_module.dart';
import '../settings/settings.dart';
import '../widgets/widgets.dart';

import '../services/self_updater.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _waitForInitialLoad();
  }

  Future<void> _waitForInitialLoad() async {
    await Future.wait([
      ref.read(initialLoadProvider.future),
      Future.delayed(const Duration(milliseconds: 2300)),
    ]);
    FlutterNativeSplash.remove();
  }

  Future<void> _showToolContextMenu(
    BuildContext context,
    Offset position,
    ToolModule module,
  ) async {
    final controller = ref.read(toolsControllerProvider);
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<int>(
      context: context,
      color: kSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: kAccent.withAlpha(50)),
      ),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(
                controller.hideOrder.contains(module.id)
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 18,
                color: const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 10),
              Text(
                controller.hideOrder.contains(module.id) ? "Show" : "Hide",
                style: TextStyle(color: kTextPrimary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
    if (selected == 1) {
      controller.toggleHide(module.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final controller = ref.watch(toolsControllerProvider);

    final favoriteTools = controller.favoriteTools;
    final nonFavoriteTools = controller.nonFavoriteTools;
    final moduleLayout = controller.moduleLayout;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            const SizedBox(width: 20),
            SizedBox(
              width: 220,
              height: 40,
              child: SearchBar(
                leading: Icon(Icons.search, color: kTextSecondary, size: 18),
                hintText: "Search",
                hintStyle: WidgetStateProperty.all(
                  TextStyle(color: kTextSecondary, fontSize: 13),
                ),
                textStyle: WidgetStateProperty.all(
                  TextStyle(color: kTextPrimary, fontSize: 13),
                ),
                backgroundColor: WidgetStateProperty.all(kBgColor),
                elevation: WidgetStateProperty.all(0),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 12),
                ),
                constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: kAccent.withAlpha(50)),
                  ),
                ),
                onChanged: controller.setSearchQuery,
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 145,
              height: 40,
              child: DropdownButtonFormField<int>(
                initialValue: controller.selectedCategory,
                isExpanded: true,
                isDense: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: kTextSecondary,
                  size: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'Category',
                  hintStyle: TextStyle(color: kTextSecondary, fontSize: 13),
                  filled: true,
                  fillColor: kBgColor,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: kAccent.withAlpha(50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: kAccent.withAlpha(50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: kAccent.withAlpha(50)),
                  ),
                ),
                dropdownColor: kSurfaceColor,
                style: TextStyle(color: kTextPrimary, fontSize: 13),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...controller.categories.asMap().entries.map(
                    (entry) => DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  ),
                ],
                onChanged: controller.setSelectedCategory,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final update = ref.watch(updateCheckProvider).valueOrNull;
              if (update == null) return const SizedBox.shrink();
              return Tooltip(
                message: 'Update to v${update.latestVersion} available',
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  border: Border.all(width: 1, color: kAccent),
                  borderRadius: BorderRadius.circular(5),
                ),
                textStyle: TextStyle(color: kTextPrimary),
                child: IconButton(
                  icon: const Icon(
                    Icons.system_update_alt,
                    color: Colors.amber,
                  ),
                  onPressed: () async {
                    if (Platform.isWindows &&
                        update.windowsDownloadUrl != null) {
                      await downloadAndInstall(update.windowsDownloadUrl!);
                    } else {
                      launchUrl(Uri.parse(update.releaseUrl));
                    }
                  },
                ),
              );
            },
          ),
          Tooltip(
            message: "Settings",
            decoration: BoxDecoration(
              color: kSurfaceColor,
              border: Border.all(width: 1, color: kAccent),
              borderRadius: BorderRadius.circular(5),
            ),
            textStyle: TextStyle(color: kTextPrimary),
            child: IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              icon: const Icon(Icons.settings),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SettingsDialog(
                    tools: controller.tools,
                    hideOrder: controller.hideOrder,
                    onUnHide: controller.unhideModule,
                    onHide: controller.hideModule,
                    moduleLayout: controller.moduleLayout,
                    onLayoutChange: controller.setModuleLayout,
                    updateInfo: ref.read(updateCheckProvider).valueOrNull,
                  ),
                  useRootNavigator: true,
                );
              },
            ),
          ),
        ],
      ),
      body: controller.filteredTools.isEmpty
          ? Center(
              child: Text(
                'No matches for "${controller.searchQuery}"',
                style: TextStyle(color: kTextSecondary, fontSize: 14),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (favoriteTools.isNotEmpty && moduleLayout != 3) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8),
                      child: Text(
                        "Favorites",
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildGrid(
                      width: width,
                      tools: favoriteTools,
                      onReorder: controller.reorderFavorites,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (moduleLayout == 1) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8),
                      child: Text(
                        "All Tools",
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildGrid(
                      width: width,
                      tools: nonFavoriteTools,
                      onReorder: controller.reorder,
                    ),
                  ],
                  if (moduleLayout == 2) ...[
                    for (final category in controller.categories)
                      if (nonFavoriteTools.any(
                        (t) => t.category == category,
                      )) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildGrid(
                          width: width,
                          tools: nonFavoriteTools
                              .where((t) => t.category == category)
                              .toList(),
                          onReorder: (a, b) =>
                              controller.reorderCategory(category, a, b),
                        ),
                      ],
                  ],
                  if (moduleLayout == 3) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8),
                      child: Text(
                        "All Tools",
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (favoriteTools.isNotEmpty)
                            CategoryDropdownColumn(
                              category: "Favorites",
                              items: favoriteTools
                                  .map(
                                    (t) => buildTabularToolRow(
                                      icon: t.icon,
                                      name: t.name,
                                      isFavorite: controller.favoriteOrder
                                          .contains(t.id),
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: t.dialogBuilder,
                                        useRootNavigator: true,
                                      ),
                                      onToggleFavorite: () =>
                                          controller.toggleFavorite(t.id),
                                      onSecondaryTapDown: (pos) =>
                                          _showToolContextMenu(context, pos, t),
                                    ),
                                  )
                                  .toList(),
                            ),
                          for (final category in controller.categories)
                            if (nonFavoriteTools.any(
                              (t) => t.category == category,
                            ))
                              CategoryDropdownColumn(
                                category: category,
                                items: nonFavoriteTools
                                    .where((t) => t.category == category)
                                    .map(
                                      (t) => buildTabularToolRow(
                                        icon: t.icon,
                                        name: t.name,
                                        isFavorite: controller.favoriteOrder
                                            .contains(t.id),
                                        onTap: () => showDialog(
                                          context: context,
                                          builder: t.dialogBuilder,
                                          useRootNavigator: true,
                                        ),
                                        onToggleFavorite: () =>
                                            controller.toggleFavorite(t.id),
                                        onSecondaryTapDown: (pos) =>
                                            _showToolContextMenu(
                                              context,
                                              pos,
                                              t,
                                            ),
                                      ),
                                    )
                                    .toList(),
                                initiallyExpanded: false,
                              ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  int _columnCount(double width) {
    if (width < 371) return 1;
    if (width < 641) return 2;
    if (width < 961) return 3;
    if (width < 1281) return 4;
    if (width < 1601) return 5;
    if (width < 1921) return 6;
    if (width < 2241) return 7;
    if (width < 2561) return 8;
    if (width < 2881) return 9;
    return 10;
  }

  Widget _buildGrid({
    required double width,
    required List<ToolModule> tools,
    required void Function(int, int) onReorder,
  }) {
    final controller = ref.read(toolsControllerProvider);
    return ReorderableGridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columnCount(width),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3.5,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) => ToolCard(
        key: ValueKey(tools[index].id),
        module: tools[index],
        isFavorite: controller.favoriteOrder.contains(tools[index].id),
        onToggleFavorite: () => controller.toggleFavorite(tools[index].id),
        onSecondaryTapDown: (position) =>
            _showToolContextMenu(context, position, tools[index]),
      ),
      onReorder: controller.isSearching ? (a, b) {} : onReorder,
      dragStartDelay: const Duration(milliseconds: 150),
    );
  }
}
