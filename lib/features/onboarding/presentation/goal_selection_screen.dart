import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import 'onboarding_widgets.dart';

/// Goal selection screen - third screen in onboarding flow - Hockey Gym V2
/// Path: /onboarding/goal
class GoalSelectionScreen extends ConsumerStatefulWidget {
  final PlayerRole role;

  const GoalSelectionScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends ConsumerState<GoalSelectionScreen> {
  TrainingGoal? _selectedGoal;

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
                          "What's your main goal?",
                          style: AppTextStyles.titleXL.copyWith(
                            fontSize: isSmallScreen ? 26 : 32,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),
                        // Goal cards
                        OnboardingSelectableCard(
                          title: 'Be stronger on the puck',
                          subtitle: 'Win battles and dominate physically',
                          icon: Icons.fitness_center,
                          isSelected: _selectedGoal == TrainingGoal.strength,
                          isCompact: isSmallScreen,
                          onTap: () {
                            setState(() {
                              _selectedGoal = TrainingGoal.strength;
                            });
                          },
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.sm + 4 : AppSpacing.md),
                        OnboardingSelectableCard(
                          title: 'Skate faster & explode on first strides',
                          subtitle: 'Improve acceleration and top speed',
                          icon: Icons.speed,
                          isSelected: _selectedGoal == TrainingGoal.speed,
                          isCompact: isSmallScreen,
                          onTap: () {
                            setState(() {
                              _selectedGoal = TrainingGoal.speed;
                            });
                          },
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.sm + 4 : AppSpacing.md),
                        OnboardingSelectableCard(
                          title: 'Last longer during shifts',
                          subtitle: 'Build endurance and stay strong all game',
                          icon: Icons.timer,
                          isSelected: _selectedGoal == TrainingGoal.endurance,
                          isCompact: isSmallScreen,
                          onTap: () {
                            setState(() {
                              _selectedGoal = TrainingGoal.endurance;
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
                    onPressed: _selectedGoal == null
                        ? null
                        : () {
                            context.push(
                              '/onboarding/plan_preview',
                              extra: {
                                'role': widget.role,
                                'goal': _selectedGoal,
                              },
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
