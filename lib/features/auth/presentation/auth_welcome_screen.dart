import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';

/// Authentication welcome screen - first screen users see
class AuthWelcomeScreen extends ConsumerWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Icon
              Icon(
                Icons.sports_hockey,
                size: 120,
                color: AppTheme.primaryColor,
              ),
              SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Hockey Gym Training',
                style: AppTextStyles.titleXL,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm + 4),

              // Subtitle
              Text(
                'Your complete hockey training companion',
                style: AppTextStyles.body.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),

              // Privacy message
              Container(
                padding: EdgeInsets.all(AppSpacing.sm + 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'All data saved locally on your device',
                        style: AppTextStyles.small.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xxl),

              // Main question
              Text(
                'What is your username?',
                style: AppTextStyles.titleL,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),

              // Enter username button
              ElevatedButton(
                onPressed: () => context.push('/auth/signup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.onPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                  ),
                ),
                child: Text(
                  'Enter Username',
                  style: AppTextStyles.button.copyWith(fontSize: 18),
                ),
              ),
              SizedBox(height: AppSpacing.md),

              // Login link for existing users
              TextButton.icon(
                onPressed: () => context.push('/auth/login'),
                icon: const Icon(Icons.login, size: 20),
                label: Text(
                  'Already have an account? Login here',
                  style: AppTextStyles.bodyMedium,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondaryTextColor,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm + 4, horizontal: AppSpacing.md),
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Feature highlights
              _buildFeatureItem(
                context,
                Icons.fitness_center,
                'Structured training programs',
              ),
              SizedBox(height: AppSpacing.sm + 4),
              _buildFeatureItem(
                context,
                Icons.trending_up,
                'Track your progress',
              ),
              SizedBox(height: AppSpacing.sm + 4),
              _buildFeatureItem(
                context,
                Icons.emoji_events,
                'Achieve your goals',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppTheme.accentColor,
        ),
        SizedBox(width: AppSpacing.sm + 4),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.grey300,
              ),
        ),
      ],
    );
  }
}
