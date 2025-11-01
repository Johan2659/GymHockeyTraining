import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(availableProgramsProvider);
    final appStateAsync = ref.watch(appStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Programs'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: programsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                'Failed to load programs',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (programs) => appStateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading app state: $error'),
          ),
          data: (appState) =>
              _buildProgramsList(context, ref, programs, appState),
        ),
      ),
    );
  }

  Widget _buildProgramsList(BuildContext context, WidgetRef ref,
      List<Program> programs, AppStateData appState) {
    if (programs.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, appState),
          const SizedBox(height: 24),
          _buildRoleCards(context, ref, programs, appState),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStateData appState) {
    // Removed Active Program Resume section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Role',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a training program designed for your hockey position',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_hockey,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No Programs Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Training programs are currently being loaded. Please try again later.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCards(BuildContext context, WidgetRef ref,
      List<Program> programs, AppStateData appState) {
    // Group programs by role
    final programsByRole = <UserRole, List<Program>>{};
    for (final program in programs) {
      programsByRole.putIfAbsent(program.role, () => []).add(program);
    }

    // Define all roles with their display info
    final roleInfo = {
      UserRole.attacker: _RoleInfo(
        title: 'Attacker',
        description: 'Offensive skills and speed training',
        icon: Icons.sports_hockey,
        color: Colors.red,
      ),
      UserRole.defender: _RoleInfo(
        title: 'Defender',
        description: 'Defensive positioning and strength',
        icon: Icons.shield,
        color: Colors.blue,
      ),
      UserRole.goalie: _RoleInfo(
        title: 'Goalie',
        description: 'Reflexes and positioning training',
        icon: Icons.sports_baseball,
        color: Colors.green,
      ),
      UserRole.referee: _RoleInfo(
        title: 'Referee',
        description: 'Conditioning and mobility training',
        icon: Icons.sports,
        color: Colors.orange,
      ),
    };

    return Column(
      children: roleInfo.entries.map((entry) {
        final role = entry.key;
        final info = entry.value;
        final rolePrograms = programsByRole[role] ?? [];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRoleCard(
            context,
            ref,
            role,
            info,
            rolePrograms,
            appState,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
    _RoleInfo info,
    List<Program> rolePrograms,
    AppStateData appState,
  ) {
    final isAvailable = rolePrograms.isNotEmpty;
    final hasActiveProgram = appState.hasActiveProgram;
    final isActiveRole =
        hasActiveProgram && appState.activeProgram?.role == role;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isAvailable && !hasActiveProgram
            ? () => _onRoleSelected(context, ref, role, rolePrograms.first)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? info.color.withOpacity(0.2)
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  info.icon,
                  size: 24,
                  color: isAvailable ? info.color : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (isAvailable && rolePrograms.isNotEmpty) ...[
                      _buildProgramStats(context, rolePrograms.first),
                    ] else ...[
                      Text(
                        'Coming Soon',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isActiveRole) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (hasActiveProgram) ...[
                Icon(
                  Icons.lock,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ] else if (isAvailable) ...[
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramStats(BuildContext context, Program program) {
    final totalSessions = program.weeks.fold<int>(
      0,
      (sum, week) => sum + week.sessions.length,
    );

    return Wrap(
      spacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 4),
            Text(
              '5 weeks',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 14,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 4),
            Text(
              '$totalSessions sessions',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  void _onRoleSelected(
      BuildContext context, WidgetRef ref, UserRole role, Program program) {
    // Navigate to program detail screen
    context.go('/programs/${program.id}');
  }

  void _resumeActiveProgram(
      BuildContext context, AppStateData appState) {
    if (!appState.hasActiveProgram) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No active program found'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final programId = appState.state?.activeProgramId ?? '';
    final week = appState.state?.currentWeek ?? 0;
    final session = appState.state?.currentSession ?? 0;

    if (programId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid program state'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Navigate directly to the current session
    context.go('/session/$programId/$week/$session');
  }
}

class _RoleInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _RoleInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
