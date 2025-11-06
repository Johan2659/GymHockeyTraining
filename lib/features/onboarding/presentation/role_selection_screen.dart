import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import 'onboarding_widgets.dart';

/// Role selection screen - second screen in onboarding flow - Hockey Gym V2
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
    final horizontalPadding = size.width < 360 ? AppSpacing.md : AppSpacing.lg;

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
                      isSmallScreen ? AppSpacing.sm : AppSpacing.md,
                      horizontalPadding,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Who are you on the ice?',
                          style: AppTextStyles.titleXL.copyWith(
                            fontSize: isSmallScreen ? 26 : 32,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),
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
                        SizedBox(height: isSmallScreen ? AppSpacing.sm + 4 : AppSpacing.md),
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
                        SizedBox(height: isSmallScreen ? AppSpacing.sm + 4 : AppSpacing.md),
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
                        SizedBox(height: isSmallScreen ? AppSpacing.sm + 4 : AppSpacing.md),
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
                    AppSpacing.md,
                    horizontalPadding,
                    isSmallScreen ? AppSpacing.md : AppSpacing.lg,
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
