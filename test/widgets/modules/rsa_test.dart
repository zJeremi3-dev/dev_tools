import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dev_tools/modules/rsa.dart';

void main() {
  Widget wrap() => const MaterialApp(home: Scaffold(body: RSADialog()));

  // Classic textbook RSA example (Wikipedia): p=61, q=53, n=3233,
  // phi=3120, e=17, d=2753. Small and deterministic on purpose — used
  // only to test the Tester mode's encrypt/decrypt logic. Key
  // *generation* itself is intentionally not tested here: it runs an
  // expensive isolate-based 1024-bit prime search that would make the
  // test suite slow and potentially flaky.
  const publicKey = '17, 3233';
  const privateKey = '2753, 3233';

  testWidgets('encrypts and decrypts text back to the original (round trip)', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Tester'));
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Hi');
    await tester.enterText(fields.at(1), publicKey);
    await tester.pump();
    await tester.enterText(fields.at(2), privateKey);
    await tester.pump();

    final outputs = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .toList();
    expect(outputs.last.data, 'Hi');
  });

  testWidgets('malformed key shows an error instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Tester'));
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Hi');
    await tester.enterText(fields.at(1), 'not a key');
    await tester.pump();

    expect(
      find.textContaining("Key must be in the format 'e, n' or 'd, n'."),
      findsOneWidget,
    );
  });

  testWidgets('a character too large for the modulus shows an error', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('Tester'));
    await tester.pump();

    final fields = find.byType(TextField);
    // 'Z' has code unit 90, which is >= a modulus of 50 -> must fail
    await tester.enterText(fields.at(0), 'Z');
    await tester.enterText(fields.at(1), '3, 50');
    await tester.pump();

    expect(find.textContaining('too small'), findsOneWidget);
  });
}
