import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../app/di.dart';
import '../../application/app_state_provider.dart';

class ProgramDetailScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailScreen({
    super.key,
    required this.programId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(programRepositoryProvider).getById(programId);
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
            error: (error, stack) => _buildErrorState(context, error.toString()),
            data: (appState) => _buildProgramDetail(context, ref, program, appState),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Program',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Program Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The requested program could not be found.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildProgramDetail(BuildContext context, WidgetRef ref, Program program, AppStateData appState) {
    final hasActiveProgram = appState.hasActiveProgram;
    final isCurrentProgram = hasActiveProgram && appState.state?.activeProgramId == program.id;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _getRoleTitle(program.role),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getRoleColor(program.role),
                    _getRoleColor(program.role).withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Icon(
                      _getRoleIcon(program.role),
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
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
              _buildStartButton(context, ref, program, hasActiveProgram, isCurrentProgram),
              const SizedBox(height: 100), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildProgramHeader(BuildContext context, Program program) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          program.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getRoleDescription(program.role),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgramStats(BuildContext context, Program program) {
    final theme = Theme.of(context);
    final totalSessions = program.weeks.fold<int>(
      0, (sum, week) => sum + week.sessions.length,
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
              theme.colorScheme.primary,
            ),
            _buildStatItem(
              context,
              Icons.fitness_center,
              totalSessions.toString(),
              'Sessions',
              theme.colorScheme.secondary,
            ),
            _buildStatItem(
              context,
              Icons.sports_hockey,
              _getRoleTitle(program.role),
              'Position',
              theme.colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBreakdown(BuildContext context, Program program) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Breakdown',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...program.weeks.map((week) => _buildWeekCard(context, week)),
      ],
    );
  }

  Widget _buildWeekCard(BuildContext context, Week week) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            week.index.toString(),
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Week ${week.index}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${week.sessions.length} sessions'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sessions:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...week.sessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sessionId = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Session ${index + 1}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Text(
                          'ID: $sessionId',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref, Program program, bool hasActiveProgram, bool isCurrentProgram) {
    final theme = Theme.of(context);

    if (isCurrentProgram) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => context.go('/hub'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text(
            'Resume from Hub',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (hasActiveProgram) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You already have an active program. Complete or pause your current program to start this one.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => context.go('/hub'),
              child: const Text(
                'Go to Hub',
                style: TextStyle(
                  fontSize: 18,
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
      height: 56,
      child: ElevatedButton(
        onPressed: () => _startProgram(context, ref, program.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getRoleColor(program.role),
          foregroundColor: Colors.white,
        ),
        child: const Text(
          'Start Program',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _startProgram(BuildContext context, WidgetRef ref, String programId) async {
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
