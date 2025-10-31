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
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Program',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
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
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Program Not Found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The requested program could not be found.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
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
              style: const TextStyle(
                fontSize: 16,
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
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildProgramHeader(context, program),
              const SizedBox(height: 24),
              _buildProgramStats(context, program),
              const SizedBox(height: 24),
              _buildWeeklyBreakdown(context, program),
              const SizedBox(height: 32),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _getRoleDescription(program.role),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
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
        padding: const EdgeInsets.all(16),
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
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...program.weeks.map((week) => _buildWeekCard(context, week)),
      ],
    );
  }

  Widget _buildWeekCard(BuildContext context, Week week) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: week.sessions.asMap().entries.map((entry) {
                final index = entry.key;
                final sessionId = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Session ${index + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        sessionId.split('_').last,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
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
          onPressed: () => context.go('/hub'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Resume from Hub',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (hasActiveProgram) {
      return Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Complete your current program to start this one.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/hub'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Go to Hub',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Start Program',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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

        // Navigate to hub
        context.go('/hub');
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
        return Colors.red;
      case UserRole.defender:
        return Colors.blue;
      case UserRole.goalie:
        return Colors.green;
      case UserRole.referee:
        return Colors.orange;
    }
  }
}
