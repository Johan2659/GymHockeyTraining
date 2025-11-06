import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import 'onboarding_widgets.dart';

/// Welcome screen - first screen in onboarding flow - Hockey Gym V2
/// Path: /onboarding/welcome
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final horizontalPadding = size.width < 360 ? AppSpacing.md : AppSpacing.lg;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xxl - 8),
                        // Top section: Logo and title
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo placeholder - you can replace with actual logo
                              Container(
                                width: isSmallScreen ? 100 : 120,
                                height: isSmallScreen ? 100 : 120,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                                  border: Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'B',
                                    style: AppTextStyles.statValue.copyWith(
                                      fontSize: isSmallScreen ? 52 : 64,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xxl - 8),
                              Text(
                                'Train like a\nhockey player.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.titleXL.copyWith(
                                  fontSize: isSmallScreen ? 28 : 36,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? AppSpacing.sm + 4 : AppSpacing.md),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                child: Text(
                                  '5-week off-ice program to get stronger,\nfaster and ready for every shift.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: AppTheme.onSurfaceColor.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xxl - 8),
                        // Bottom section: CTA buttons
                        Column(
                          children: [
                            OnboardingButton(
                              label: "Let's start",
                              onPressed: () {
                                context.push('/onboarding/role');
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to login screen
                                // For now, just show a snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Login feature coming soon'),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
                              ),
                              child: Text(
                                'Already have an account? Log in',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
