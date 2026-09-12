import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/data/tools_repository.dart';

void main() {
  group('kTools data integrity', () {
    test('every tool has a unique id', () {
      final ids = kTools.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every tool has a unique name', () {
      final names = kTools.map((t) => t.name).toList();
      expect(names.toSet().length, names.length);
    });

    test('every tool has a category listed in kCategories', () {
      for (final tool in kTools) {
        expect(
          kCategories.contains(tool.category),
          isTrue,
          reason: '"${tool.name}" uses unknown category "${tool.category}"',
        );
      }
    });

    test('every tool has a non-empty name and description', () {
      for (final tool in kTools) {
        expect(tool.name.trim(), isNotEmpty);
        expect(tool.description.trim(), isNotEmpty);
      }
    });

    test('ids are whole numbers despite being stored as double', () {
      for (final tool in kTools) {
        expect(
          tool.id == tool.id.roundToDouble(),
          isTrue,
          reason: '"${tool.name}" has a non-integer id (${tool.id})',
        );
      }
    });

    test('kCategories has no duplicates', () {
      expect(kCategories.toSet().length, kCategories.length);
    });
  });
}
