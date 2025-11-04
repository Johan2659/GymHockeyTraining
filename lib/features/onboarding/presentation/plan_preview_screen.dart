import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../../app/di.dart';
import '../../application/app_state_provider.dart';
import 'onboarding_widgets.dart';

/// Plan preview screen - final screen in onboarding flow
/// Path: /onboarding/plan_preview
class PlanPreviewScreen extends ConsumerStatefulWidget {
  final PlayerRole role;
  final TrainingGoal goal;

  const PlanPreviewScreen({
    super.key,
    required this.role,
    required this.goal,
  });

  @override
  ConsumerState<PlanPreviewScreen> createState() => _PlanPreviewScreenState();
}

class _PlanPreviewScreenState extends ConsumerState<PlanPreviewScreen> {
  bool _isLoading = false;

  /// Maps PlayerRole to program ID
  String _getProgramIdForRole(PlayerRole role) {
    switch (role) {
      case PlayerRole.forward:
        return 'hockey_attacker_2025';
      case PlayerRole.defence:
        return 'hockey_defender_2025';
      case PlayerRole.goalie:
        return 'hockey_goalie_2025';
      case PlayerRole.referee:
        return 'hockey_referee_2025';
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update the current user profile with onboarding completion
      final authRepo = ref.read(authRepositoryProvider);
      final currentUser = await authRepo.getCurrentUser();
      
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user logged in. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final updatedProfile = currentUser.copyWith(
        role: widget.role,
        goal: widget.goal,
        onboardingCompleted: true,
      );

      final success = await authRepo.updateUserProfile(updatedProfile);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save profile. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Automatically start the program based on the player's role
      final programId = _getProgramIdForRole(widget.role);
      
      try {
        await ref.read(startProgramActionProvider(programId).future);
      } catch (e) {
        // Log error but don't block onboarding completion
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile saved, but failed to start program: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (mounted) {
        // Navigate to home and remove all previous routes
        context.go('/');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
          onPressed: _isLoading ? null : () => context.pop(),
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
                          'Your 5-week Beast Cycle',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: isSmallScreen ? 26 : 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          'We rotate strength, hypertrophy and Beast PR so you build real on-ice power. You can restart the 5-week cycle anytime.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: isSmallScreen ? 14 : 16,
                                height: 1.5,
                                color: AppTheme.onSurfaceColor.withOpacity(0.8),
                              ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        // Timeline steps
                        _buildTimelineStep(
                          context,
                          step: 1,
                          label: 'Weeks 1–2',
                          title: 'Strength',
                          description: 'Build raw power for battles and shots.',
                          isLast: false,
                          isCompact: isSmallScreen,
                        ),
                        _buildTimelineStep(
                          context,
                          step: 2,
                          label: 'Weeks 3–4',
                          title: 'Hypertrophy',
                          description: 'Add muscle and volume while staying athletic.',
                          isLast: false,
                          isCompact: isSmallScreen,
                        ),
                        _buildTimelineStep(
                          context,
                          step: 3,
                          label: 'Week 5',
                          title: 'Beast PR Week',
                          description: 'Test your strength and push PRs like a beast.',
                          isLast: true,
                          isCompact: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        // Bullet points
                        _buildBulletPoint(
                          context,
                          'Hockey-specific workouts for your role',
                          isCompact: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        _buildBulletPoint(
                          context,
                          'Simple sessions — just hit Start and follow the timer',
                          isCompact: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        _buildBulletPoint(
                          context,
                          'Advanced players can customize later with Beast League Pro',
                          isCompact: isSmallScreen,
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed bottom section
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OnboardingButton(
                        label: 'Start my first workout',
                        onPressed: _isLoading ? null : _completeOnboarding,
                        isLoading: _isLoading,
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _showHowItWorksSheet(context);
                              },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          'How it works',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required int step,
    required String label,
    required String title,
    required String description,
    required bool isLast,
    bool isCompact = false,
  }) {
    final circleSize = isCompact ? 36.0 : 40.0;
    final lineHeight = isCompact ? 48.0 : 60.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.backgroundColor,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: lineHeight,
                color: AppTheme.accentColor.withOpacity(0.3),
              ),
          ],
        ),
        SizedBox(width: isCompact ? 12 : 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isCompact ? 11 : 12,
                    ),
              ),
              SizedBox(height: isCompact ? 2 : 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: isCompact ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                    ),
              ),
              SizedBox(height: isCompact ? 2 : 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isCompact ? 13 : 14,
                      color: AppTheme.onSurfaceColor.withOpacity(0.7),
                    ),
              ),
              if (!isLast) SizedBox(height: isCompact ? 12 : 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text, {bool isCompact = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isCompact ? 4.0 : 6.0),
          child: Container(
            width: isCompact ? 5 : 6,
            height: isCompact ? 5 : 6,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: isCompact ? 10 : 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceColor.withOpacity(0.9),
                  fontSize: isCompact ? 13 : 15,
                ),
          ),
        ),
      ],
    );
  }

  void _showHowItWorksSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24.0,
            24.0,
            24.0,
            24.0 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: isSmallScreen ? 22 : 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'The Beast Cycle is designed to make you stronger, faster, and more explosive on the ice.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: AppTheme.onSurfaceColor.withOpacity(0.9),
                      ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  '• Weeks 1-2: Focus on heavy weights and low reps to build maximum strength',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: AppTheme.onSurfaceColor.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Weeks 3-4: Increase volume to build muscle while maintaining strength',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: AppTheme.onSurfaceColor.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Week 5: Test your limits with PR attempts and measure your progress',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: AppTheme.onSurfaceColor.withOpacity(0.8),
                      ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
