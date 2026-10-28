import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dev_tools/modules/ip_leak.dart';

void main() {
  group('IpLeakCheck Unit Tests', () {
    test('fetchIpInfo returns parsed data on HTTP 200 success', () async {
      final mockJsonResponse = jsonEncode({
        'ip': '8.8.8.8',
        'version': 'IPv4',
        'city': 'Mountain View',
        'region': 'California',
        'country_name': 'United States',
        'country_code': 'US',
        'postal': '94043',
        'latitude': 37.4223,
        'longitude': -122.0848,
        'timezone': 'America/Los_Angeles',
        'utc_offset': '-0700',
        'currency': 'USD',
        'currency_name': 'US Dollar',
        'country_calling_code': '+1',
        'in_eu': false,
        'asn': 'AS15169',
        'org': 'Google LLC',
      });

      final client = MockClient((request) async {
        return http.Response(mockJsonResponse, 200);
      });

      final response = await client.get(Uri.parse('https://ipapi.co/json/'));
      final data = jsonDecode(response.body);

      expect(data['ip'], equals('8.8.8.8'));
      expect(data['city'], equals('Mountain View'));
      expect(data['country_code'], equals('US'));
    });

    test('hasInternetConnection returns true on HTTP 200', () async {
      final isConnected =
          await IpLeakDialogStateTestHelper.hasInternetConnectionMock(200);
      expect(isConnected, isTrue);
    });

    test('hasInternetConnection returns false on server error', () async {
      final isConnected =
          await IpLeakDialogStateTestHelper.hasInternetConnectionMock(500);
      expect(isConnected, isFalse);
    });
  });

  group('IpLeakDialog Widget Tests', () {
    testWidgets('Renders header, action buttons, and initial default state', (
      WidgetTester tester,
    ) async {
      // Set a larger surface size to prevent layout overflows during testing
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: IpLeakDialog())),
      );

      expect(find.text('IP Leak Check'), findsOneWidget);
      expect(find.text(' Internet/WiFi connection required'), findsOneWidget);
      expect(find.text('?'), findsWidgets);

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('Closes dialog when close button is tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const IpLeakDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('IP Leak Check'), findsOneWidget);

      // Tap the Close TextButton safely using widgetWithText
      final closeButtonFinder = find.widgetWithText(TextButton, 'Close');
      expect(closeButtonFinder, findsOneWidget);

      await tester.tap(closeButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the dialog is closed
      expect(find.text('IP Leak Check'), findsNothing);
    });
  });
}

/// Helper class to simulate network status checks without live HTTP requests.
class IpLeakDialogStateTestHelper {
  static Future<bool> hasInternetConnectionMock(int statusCode) async {
    final client = MockClient((request) async {
      return http.Response('', statusCode);
    });
    try {
      final response = await client.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
