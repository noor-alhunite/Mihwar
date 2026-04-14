// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:msar_flutter/app/app.dart';

void main() {
  testWidgets('Role selection screen is shown on startup', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WasteApp());

    expect(find.text('Select Role'), findsOneWidget);
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Supervisor'), findsOneWidget);
    expect(find.text('Governorate Manager'), findsOneWidget);
  });
}
