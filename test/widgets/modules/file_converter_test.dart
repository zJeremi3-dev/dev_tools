import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dev_tools/modules/file_converter.dart';

void main() {
  group('Unit Tests: targetsFor', () {
    test('returns correct output targets for image inputs', () {
      final targets = targetsFor('png');
      expect(targets, contains('jpg'));
      expect(targets, contains('gif'));
      expect(targets, contains('bmp'));
      expect(targets, contains('tiff'));
      expect(targets, contains('tga'));
      expect(targets, contains('ico'));
      expect(targets, contains('base64'));
      expect(
        targets,
        isNot(contains('png')),
      ); // Self-extension should be removed
    });

    test('handles jpeg extension correctly (removes jpg)', () {
      final targets = targetsFor('jpeg');
      expect(targets, isNot(contains('jpg')));
      expect(targets, contains('png'));
    });

    test('returns correct output targets for text inputs', () {
      final targets = targetsFor('txt');
      expect(targets, contains('pdf'));
      expect(targets, contains('html'));
      expect(targets, contains('base64'));
      expect(targets, isNot(contains('txt'))); // Self-extension removed
    });

    test('includes formatted json target for json input', () {
      final targets = targetsFor('json');
      expect(targets, contains('json (formatted)'));
      expect(targets, contains('pdf'));
      expect(targets, contains('html'));
      expect(targets, contains('txt'));
      expect(targets, contains('base64'));
    });

    test('returns only base64 for unsupported extensions', () {
      final targets = targetsFor('unknown_ext');
      expect(targets, equals(['base64']));
    });
  });

  group('Widget Tests: FileConverterDialog UI', () {
    Widget buildTestableWidget() {
      return const MaterialApp(home: Scaffold(body: FileConverterDialog()));
    }

    testWidgets('renders initial UI state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      // Verify Header
      expect(find.text('File Converter'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Verify File Picker Initial State
      expect(find.text('Select File..'), findsOneWidget);
      expect(find.text('Select File'), findsOneWidget);
      expect(find.byIcon(Icons.upload), findsOneWidget);

      // Verify Format Dropdown Hint
      expect(find.text('Format'), findsOneWidget);

      // Verify Action Buttons
      expect(find.byIcon(Icons.transform), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.text('Start Convert..'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('closes dialog when close button or icon is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const FileConverterDialog(),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('File Converter'), findsOneWidget);

      // Tap top close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('File Converter'), findsNothing);
    });

    testWidgets(
      'shows snackbar when attempting to convert without selecting a file',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());

        // Tap convert icon button
        await tester.tap(find.byIcon(Icons.transform));
        await tester.pump();

        expect(find.text('Please select a file first.'), findsOneWidget);
      },
    );

    testWidgets('download button is disabled when no result bytes exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      final iconButtonFinder = find.ancestor(
        of: find.byIcon(Icons.download),
        matching: find.byType(IconButton),
      );

      final IconButton iconButton = tester.widget(iconButtonFinder);
      expect(iconButton.onPressed, isNull);
    });
  });
}
