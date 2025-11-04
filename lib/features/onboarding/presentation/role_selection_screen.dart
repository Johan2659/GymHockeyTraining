import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import 'onboarding_widgets.dart';

/// Role selection screen - second screen in onboarding flow
/// Path: /onboarding/role
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  PlayerRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final horizontalPadding = size.width < 360 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 24,
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isSmallScreen ? 8.0 : 16.0,
                      horizontalPadding,
                      16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Who are you on the ice?',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: isSmallScreen ? 26 : 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 32),
                        // Role cards
                        OnboardingSelectableCard(
                          title: 'Forward',
                          subtitle: 'Speed & explosiveness',
                          icon: Icons.flash_on,
                          isSelected: _selectedRole == PlayerRole.forward,
                          isCompact: isSmallScreen,
                          onTap: () {
                            setState(() {
                              _selectedRole = PlayerRole.forward;
                            });
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        OnboardingSelectableCard(
                          title: 'Defence',
                          subtitle: 'Power & stability',
                          icon: Icons.shield,
                          isSelected: _selectedRole == PlayerRole.defence,
                          isCompact: isSmallScreen,
                          onTap: () {
                            setState(() {
                              _selectedRole = PlayerRole.defence;
                            });
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        OnboardingSelectableCard(
                          title: 'Goalie',
                          subtitle: 'Mobility & reflexes',
                          icon: Icons.sports_hockey,
                          isSelected: _selectedRole == PlayerRole.goalie,
                          isCompact: isSmallScreen,
                          onTap: () {
                            setState(() {
                              _selectedRole = PlayerRole.goalie;
                            });
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        OnboardingSelectableCard(
                          title: 'Referee',
                          subtitle: 'Endurance & agility',
                          icon: Icons.sports,
                          isSelected: _selectedRole == PlayerRole.referee,
                          isCompact: isSmallScreen,
                          onTap: () {
                            setState(() {
                              _selectedRole = PlayerRole.referee;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed bottom button
                Container(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16.0,
                    horizontalPadding,
                    isSmallScreen ? 16.0 : 24.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: OnboardingButton(
                    label: 'Continue',
                    onPressed: _selectedRole == null
                        ? null
                        : () {
                            context.push(
                              '/onboarding/goal',
                              extra: _selectedRole,
                            );
                          },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
