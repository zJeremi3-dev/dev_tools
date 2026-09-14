import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_tools/data/daten_manager.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('order lists (favorite / normal / hide)', () {
    test(
      'loadFavoriteOrder returns an empty list when nothing was saved',
      () async {
        expect(await DatenManager.loadFavoriteOrder(), isEmpty);
      },
    );

    test(
      'saveFavoriteOrder + loadFavoriteOrder round-trips correctly',
      () async {
        await DatenManager.saveFavoriteOrder([1, 3, 7]);
        expect(await DatenManager.loadFavoriteOrder(), [1.0, 3.0, 7.0]);
      },
    );

    test('saveNormalOrder + loadNormalOrder round-trips correctly', () async {
      await DatenManager.saveNormalOrder([5, 2, 9]);
      expect(await DatenManager.loadNormalOrder(), [5.0, 2.0, 9.0]);
    });

    test('saveHideOrder + loadHideOrder round-trips correctly', () async {
      await DatenManager.saveHideOrder([4]);
      expect(await DatenManager.loadHideOrder(), [4.0]);
    });

    test(
      'loadFavoriteOrder returns an empty list instead of crashing on corrupted data',
      () async {
        SharedPreferences.setMockInitialValues({
          DatenManager.keyFavoriteOrder: 'not-valid-json{{{',
        });
        expect(await DatenManager.loadFavoriteOrder(), isEmpty);
      },
    );
  });

  group('color scheme', () {
    test('defaults to scheme 1 when nothing was saved', () async {
      expect(await DatenManager.loadColorScheme(), 1);
    });

    test('saveColorScheme + loadColorScheme round-trips correctly', () async {
      await DatenManager.saveColorScheme(7);
      expect(await DatenManager.loadColorScheme(), 7);
    });
  });

  group('module layout', () {
    test('defaults to 1 when nothing was saved', () async {
      expect(await DatenManager.loadModuleLayout(), 1);
    });

    test('saveModuleLayout + loadModuleLayout round-trips correctly', () async {
      await DatenManager.saveModuleLayout(3);
      expect(await DatenManager.loadModuleLayout(), 3);
    });
  });
}
