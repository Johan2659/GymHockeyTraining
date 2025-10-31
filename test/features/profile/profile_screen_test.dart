import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymhockeytraining/features/profile/presentation/profile_screen.dart';

void main() {
  group('ProfileScreen Tests', () {
    testWidgets('should display profile screen with default settings',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify the screen is displayed
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);

      // Verify setting cards are present
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);

      // Verify action buttons are present
      expect(find.text('Reset Progress'), findsOneWidget);
      expect(find.text('Export Logs'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('should show role selector dialog when role setting is tapped',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the role setting
      await tester.tap(find.text('Role'));
      await tester.pumpAndSettle();

      // Verify the role selector dialog is shown
      expect(find.text('Select Role'), findsOneWidget);
      expect(find.text('Attacker'), findsOneWidget);
      expect(find.text('Defender'), findsOneWidget);
      expect(find.text('Goalie'), findsOneWidget);
      expect(find.text('Referee'), findsOneWidget);
    });

    testWidgets('should show confirmation dialog for reset progress',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on reset progress
      await tester.tap(find.text('Reset Progress'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Reset Progress'), findsNWidgets(2)); // Title and button
      expect(
          find.text(
              'Are you sure you want to reset all your training progress?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('should show confirmation dialog for delete account',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on delete account
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete Account'), findsNWidgets(2)); // Title and button
      expect(find.textContaining('This will permanently delete ALL your data'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
