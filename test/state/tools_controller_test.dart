import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_tools/state/tools_controller.dart';
import 'package:dev_tools/colors.dart';

void main() {
  // ToolsController persists via DatenManager -> SharedPreferences.
  // Mocking the plugin's initial values lets it run in plain unit tests
  // without a device/emulator.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('filteredTools', () {
    test('returns all tools when no filters are active', () {
      final c = ToolsController();
      expect(c.filteredTools.length, c.tools.length);
    });

    test('excludes hidden tools', () {
      final c = ToolsController();
      final firstId = c.tools.first.id;

      c.hideModule(firstId);

      expect(c.filteredTools.any((t) => t.id == firstId), isFalse);
    });

    test('restores a tool after unhide', () {
      final c = ToolsController();
      final firstId = c.tools.first.id;

      c.hideModule(firstId);
      c.unhideModule(firstId);

      expect(c.filteredTools.any((t) => t.id == firstId), isTrue);
    });

    test('filters by selected category', () {
      final c = ToolsController();
      final categoryIndex = c.categories.indexOf('Security');

      c.setSelectedCategory(categoryIndex);

      expect(c.filteredTools, isNotEmpty);
      expect(c.filteredTools.every((t) => t.category == 'Security'), isTrue);
    });

    test('search matches name case-insensitively', () {
      final c = ToolsController();

      c.setSearchQuery('password');

      expect(c.filteredTools, isNotEmpty);
      expect(
        c.filteredTools.every(
          (t) =>
              t.name.toLowerCase().contains('password') ||
              t.description.toLowerCase().contains('password'),
        ),
        isTrue,
      );
    });

    test('search matches description too', () {
      final c = ToolsController();

      c.setSearchQuery('sha-256');

      expect(c.filteredTools.any((t) => t.name == 'Hash Generator'), isTrue);
    });

    test('search with no matches returns an empty list', () {
      final c = ToolsController();

      c.setSearchQuery('this tool does not exist');

      expect(c.filteredTools, isEmpty);
    });

    test('isSearching reflects whether the query is non-blank', () {
      final c = ToolsController();
      expect(c.isSearching, isFalse);

      c.setSearchQuery('   ');
      expect(c.isSearching, isFalse);

      c.setSearchQuery('qr');
      expect(c.isSearching, isTrue);
    });
  });

  group('favorites', () {
    test('toggleFavorite adds then removes a tool from favoriteOrder', () {
      final c = ToolsController();
      final id = c.tools.first.id;

      c.toggleFavorite(id);
      expect(c.favoriteOrder.contains(id), isTrue);

      c.toggleFavorite(id);
      expect(c.favoriteOrder.contains(id), isFalse);
    });

    test('favoriteTools and nonFavoriteTools are disjoint and complete', () {
      final c = ToolsController();
      c.toggleFavorite(c.tools[0].id);
      c.toggleFavorite(c.tools[2].id);

      final favIds = c.favoriteTools.map((t) => t.id).toSet();
      final nonFavIds = c.nonFavoriteTools.map((t) => t.id).toSet();

      expect(favIds.intersection(nonFavIds), isEmpty);
      expect(favIds.length + nonFavIds.length, c.filteredTools.length);
    });

    test('favoriteTools respects favoriteOrder, not insertion order', () {
      final c = ToolsController();
      final a = c.tools[0].id;
      final b = c.tools[1].id;

      c.toggleFavorite(a);
      c.toggleFavorite(b);
      // favoriteOrder is now [a, b]
      expect(c.favoriteTools.map((t) => t.id).toList(), [a, b]);

      c.reorderFavorites(0, 1); // swap so b comes first
      expect(c.favoriteTools.map((t) => t.id).toList(), [b, a]);
    });
  });

  group('module layout', () {
    test('defaults to 1 and updates on setModuleLayout', () {
      final c = ToolsController();
      expect(c.moduleLayout, 1);

      c.setModuleLayout(3);
      expect(c.moduleLayout, 3);
    });
  });

  group('reorder', () {
    test('reorder moves a tool within the non-favorite set only', () {
      final c = ToolsController();
      final favoriteId = c.tools[0].id;
      c.toggleFavorite(favoriteId);

      final before = c.nonFavoriteTools.map((t) => t.id).toList();
      final moved = before[2];

      c.reorder(2, 0);

      final after = c.nonFavoriteTools.map((t) => t.id).toList();
      expect(after.first, moved);
      // the favorited tool never re-appears in the non-favorite list
      expect(after.contains(favoriteId), isFalse);
    });

    test('reorder does not disturb favorited tools', () {
      final c = ToolsController();
      final favoriteId = c.tools[1].id;
      c.toggleFavorite(favoriteId);

      c.reorder(0, 3);

      expect(c.favoriteOrder, [favoriteId]);
      expect(c.favoriteTools.single.id, favoriteId);
    });

    test('reorderCategory only reorders tools within that category', () {
      final c = ToolsController();
      final generatorIdsBefore = c.nonFavoriteTools
          .where((t) => t.category == 'Generator')
          .map((t) => t.id)
          .toList();
      final otherIdsBefore = c.nonFavoriteTools
          .where((t) => t.category != 'Generator')
          .map((t) => t.id)
          .toList();

      // move the first Generator tool to the end of the Generator group
      c.reorderCategory('Generator', 0, generatorIdsBefore.length - 1);

      final otherIdsAfter = c.nonFavoriteTools
          .where((t) => t.category != 'Generator')
          .map((t) => t.id)
          .toList();
      final generatorIdsAfter = c.nonFavoriteTools
          .where((t) => t.category == 'Generator')
          .map((t) => t.id)
          .toList();

      // tools outside "Generator" are untouched, in the same relative order
      expect(otherIdsAfter, otherIdsBefore);
      // the moved tool (formerly first) is now last within its category,
      // and everything else shifted up by one
      final expected = [
        ...generatorIdsBefore.skip(1),
        generatorIdsBefore.first,
      ];
      expect(generatorIdsAfter, expected);
    });

    test('reorderFavorites reorders only the favorites list', () {
      final c = ToolsController();
      final a = c.tools[0].id;
      final b = c.tools[1].id;
      final c_ = c.tools[2].id;
      c.toggleFavorite(a);
      c.toggleFavorite(b);
      c.toggleFavorite(c_);

      c.reorderFavorites(2, 0); // move last favorite to the front

      expect(c.favoriteOrder, [c_, a, b]);
    });
  });

  group('persistence', () {
    test('load() restores previously saved state', () async {
      final prefs = await SharedPreferences.getInstance();
      final first = ToolsController();
      final id = first.tools.first.id;

      first.toggleFavorite(id);
      first.hideModule(first.tools[1].id);
      first.setModuleLayout(2);

      // simulate app restart: fresh controller instance reads from the
      // same (mocked) SharedPreferences backing store
      final second = ToolsController();
      await second.load();

      expect(second.favoriteOrder.contains(id), isTrue);
      expect(second.hideOrder.contains(first.tools[1].id), isTrue);
      expect(second.moduleLayout, 2);

      // sanity check that we're really reading from storage, not memory
      expect(prefs.getString('favorite_order'), isNotNull);
    });
  });

  group('notifyListeners', () {
    test('mutating methods notify listeners', () {
      final c = ToolsController();
      var notifications = 0;
      c.addListener(() => notifications++);

      c.toggleFavorite(c.tools.first.id);
      c.hideModule(c.tools[1].id);
      c.setModuleLayout(3);
      c.setSearchQuery('x');

      expect(notifications, 4);
    });
  });

  group('color scheme persistence', () {
    test('load() restores the previously saved color scheme', () async {
      final first = ToolsController();
      first.setColorScheme(5);

      final second = ToolsController();
      await second.load();

      expect(selectedScheme, 5);
    });
  });
}
