import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/hash_generator.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: HashGenDialog()));

  Future<void> selectAlgo(WidgetTester tester, String algo) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(algo).last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows placeholder when input is empty', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('computes correct SHA-256 for "hello" (default algorithm)', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    expect(
      find.text(
        '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
      ),
      findsOneWidget,
    );
  });

  testWidgets('computes correct MD5 for "hello"', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await selectAlgo(tester, 'MD5');
    expect(find.text('5d41402abc4b2a76b9719d911017c592'), findsOneWidget);
  });

  testWidgets('computes correct SHA-1 for "hello"', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await selectAlgo(tester, 'SHA-1');
    expect(
      find.text('aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d'),
      findsOneWidget,
    );
  });

  testWidgets('computes correct SHA-512 for "hello"', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await selectAlgo(tester, 'SHA-512');
    expect(
      find.text(
        '9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca'
        '72323c3d99ba5c11d7c7acc6e14b8c5da0c4663475c2e5c3adef46f73bcdec043',
      ),
      findsOneWidget,
    );
  });

  testWidgets('changing the input updates the hash', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    final hashA = tester
        .widget<SelectableText>(find.byType(SelectableText))
        .data;

    await tester.enterText(find.byType(TextField), 'b');
    await tester.pump();
    final hashB = tester
        .widget<SelectableText>(find.byType(SelectableText))
        .data;

    expect(hashA, isNot(equals(hashB)));
  });
}
