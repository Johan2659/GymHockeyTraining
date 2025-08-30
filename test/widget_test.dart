// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymhockeytraining/app/app.dart';

void main() {
  testWidgets('Hockey Gym app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: HockeyGymApp()));

    // Verify that our app shows the welcome screen
    expect(find.text('Welcome to Hockey Gym'), findsOneWidget);
    expect(find.text('Your hockey training hub'), findsOneWidget);

    // Verify that we can find the hockey icon
    expect(find.byIcon(Icons.sports_hockey), findsOneWidget);
  });
}
