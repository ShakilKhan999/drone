// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raveneye/main.dart'; // Imports RavenEyeApp
import 'package:raveneye/views/home_screen.dart'; // Import HomeScreen if needed for specific finds

void main() {
  // Mock necessary initializations if required (e.g., Hive, GetX bindings)
  // setUpAll(() async {
  //   // Mock Hive init if main() does complex setup
  // });

  testWidgets('App builds and shows HomeScreen when permissions granted',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Assume permissions are granted for this test case.
    await tester.pumpWidget(const RavenEyeApp(permissionsGranted: true));

    // Verify that the HomeScreen is displayed (e.g., check for its AppBar title).
    expect(find.text('RavenEye Lite'), findsOneWidget);

    // Verify that the initial status text is present.
    expect(find.text('Monitoring... No Drone Nearby'), findsOneWidget);

    // Verify one of the toggle switches is present
    expect(find.text('Wi-Fi Scanner'), findsOneWidget);
  });

  testWidgets('App shows PermissionsDeniedScreen when permissions not granted',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Assume permissions are NOT granted for this test case.
    await tester.pumpWidget(const RavenEyeApp(permissionsGranted: false));

    // Verify that the PermissionsDeniedScreen is displayed.
    expect(find.text('Permissions Required'), findsOneWidget);
    expect(find.text('Open App Settings'), findsOneWidget);

    // Verify HomeScreen elements are not present
    expect(find.text('RavenEye Lite'), findsNothing);
  });
}
