import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import 'onboarding_widgets.dart';

/// Welcome screen - first screen in onboarding flow
/// Path: /onboarding/welcome
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final horizontalPadding = size.width < 360 ? 16.0 : 24.0;

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
                      vertical: isSmallScreen ? 16.0 : 24.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: isSmallScreen ? 20 : 40),
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
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppTheme.accentColor,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'B',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 52 : 64,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 24 : 40),
                              Text(
                                'Train like a\nhockey player.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontSize: isSmallScreen ? 28 : 36,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                      color: AppTheme.onSurfaceColor,
                                    ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '5-week off-ice program to get stronger,\nfaster and ready for every shift.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        height: 1.5,
                                        color: AppTheme.onSurfaceColor.withOpacity(0.8),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        // Bottom section: CTA buttons
                        Column(
                          children: [
                            OnboardingButton(
                              label: "Let's start",
                              onPressed: () {
                                context.push('/onboarding/role');
                              },
                            ),
                            const SizedBox(height: 16),
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Text(
                                'Already have an account? Log in',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 14,
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
