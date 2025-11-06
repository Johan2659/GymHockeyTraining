import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';

class ProgramDetailScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailScreen({
    super.key,
    required this.programId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync =
        ref.watch(programRepositoryProvider).getById(programId);
    final appStateAsync = ref.watch(appStateProvider);

    return Scaffold(
      body: FutureBuilder<Program?>(
        future: programAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error.toString());
          }

          final program = snapshot.data;
          if (program == null) {
            return _buildNotFoundState(context);
          }

          return appStateAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                _buildErrorState(context, error.toString()),
            data: (appState) =>
                _buildProgramDetail(context, ref, program, appState),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Error Loading Program',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                error,
                style: AppTextStyles.small,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text('Go Back', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppTheme.grey600,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Program Not Found',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'The requested program could not be found.',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text('Go Back', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramDetail(BuildContext context, WidgetRef ref,
      Program program, AppStateData appState) {
    final hasActiveProgram = appState.hasActiveProgram;
    final isCurrentProgram =
        hasActiveProgram && appState.state?.activeProgramId == program.id;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          backgroundColor: AppTheme.surfaceColor,
          foregroundColor: AppTheme.onSurfaceColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _getRoleTitle(program.role),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                border: Border(
                  bottom: BorderSide(
                    color: _getRoleColor(program.role).withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    _getRoleIcon(program.role),
                    size: 48,
                    color: _getRoleColor(program.role).withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.card,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildProgramHeader(context, program),
              const SizedBox(height: AppSpacing.lg),
              _buildProgramStats(context, program),
              const SizedBox(height: AppSpacing.lg),
              _buildWeeklyBreakdown(context, program),
              const SizedBox(height: AppSpacing.xl),
              _buildStartButton(
                  context, ref, program, hasActiveProgram, isCurrentProgram),
              const SizedBox(height: 100), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildProgramHeader(BuildContext context, Program program) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          program.title,
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _getRoleDescription(program.role),
          style: AppTextStyles.body.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
        ),
      ],
    );
  }

  Widget _buildProgramStats(BuildContext context, Program program) {
    final totalSessions = program.weeks.fold<int>(
      0,
      (sum, week) => sum + week.sessions.length,
    );

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              Icons.schedule,
              '5',
              'Weeks',
              AppTheme.primaryColor,
            ),
            _buildStatItem(
              context,
              Icons.fitness_center,
              totalSessions.toString(),
              'Sessions',
              AppTheme.accentColor,
            ),
            _buildStatItem(
              context,
              Icons.sports_hockey,
              _getRoleTitle(program.role),
              'Position',
              _getRoleColor(program.role),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.subtitle.copyWith(
                color: color,
              ),
        ),
        Text(
          label,
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  Widget _buildWeeklyBreakdown(BuildContext context, Program program) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Breakdown',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        ...program.weeks.map((week) => _buildWeekCard(context, week)),
      ],
    );
  }

  Widget _buildWeekCard(BuildContext context, Week week) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
          child: Center(
            child: Text(
              week.index.toString(),
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          'Week ${week.index}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${week.sessions.length} sessions',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: week.sessions.asMap().entries.map((entry) {
                final index = entry.key;
                final sessionId = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Session ${index + 1}',
                          style: AppTextStyles.small,
                        ),
                      ),
                      Text(
                        sessionId.split('_').last,
                        style: AppTextStyles.caption.copyWith(
                              color: AppTheme.grey500,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref, Program program,
      bool hasActiveProgram, bool isCurrentProgram) {
    if (isCurrentProgram) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _resumeProgram(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.onPrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          child: Text(
            'Resume Program',
            style: AppTextStyles.button,
          ),
        ),
      );
    }

    if (hasActiveProgram) {
      return Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Text(
                      'Complete your current program to start this one.',
                      style: AppTextStyles.small,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/hub'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: Text(
                'Go to Hub',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _startProgram(context, ref, program.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getRoleColor(program.role),
          foregroundColor: AppTheme.onPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: Text(
          'Start Program',
          style: AppTextStyles.button,
        ),
      ),
    );
  }

  void _startProgram(
      BuildContext context, WidgetRef ref, String programId) async {
    try {
      // Start the program using the action provider
      await ref.read(startProgramActionProvider(programId).future);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Program started successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Navigate directly to the first session (week 0, session 0)
        context.go('/session/$programId/0/0');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start program: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _resumeProgram(BuildContext context, WidgetRef ref) async {
    try {
      // Get the current app state to find the next session
      final appState = await ref.read(appStateProvider.future);

      if (!appState.hasActiveProgram) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No active program found'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      final programId = appState.state?.activeProgramId ?? '';
      final week = appState.state?.currentWeek ?? 0;
      final session = appState.state?.currentSession ?? 0;

      if (programId.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid program state'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      // Navigate directly to the current session
      if (context.mounted) {
        context.go('/session/$programId/$week/$session');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resume program: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.attacker:
        return 'Attacker';
      case UserRole.defender:
        return 'Defender';
      case UserRole.goalie:
        return 'Goalie';
      case UserRole.referee:
        return 'Referee';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.attacker:
        return 'Develop your offensive skills, speed, and goal-scoring abilities with specialized drills and conditioning.';
      case UserRole.defender:
        return 'Master defensive positioning, body checking, and puck control to become an elite defender.';
      case UserRole.goalie:
        return 'Enhance your reflexes, positioning, and mental game to become an unbeatable goaltender.';
      case UserRole.referee:
        return 'Improve your conditioning, mobility, and game awareness to officiate at the highest level.';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.attacker:
        return Icons.sports_hockey;
      case UserRole.defender:
        return Icons.shield;
      case UserRole.goalie:
        return Icons.sports_baseball;
      case UserRole.referee:
        return Icons.sports;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.attacker:
        return AppTheme.error;
      case UserRole.defender:
        return Colors.blue;
      case UserRole.goalie:
        return Colors.green;
      case UserRole.referee:
        return Colors.orange;
    }
  }
}
