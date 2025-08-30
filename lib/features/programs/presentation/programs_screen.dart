import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
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
          data: (appState) => _buildProgramsList(context, ref, programs, appState),
        ),
      ),
    );
  }

  Widget _buildProgramsList(BuildContext context, WidgetRef ref, List<Program> programs, AppStateData appState) {
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
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (appState.hasActiveProgram) ...[
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You have an active program',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.activeProgram?.title ?? 'Unknown Program',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/hub'),
                    child: const Text('Resume'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'Choose Your Role',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a training program designed for your hockey position',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_hockey,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Programs Available',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Training programs are currently being loaded. Please try again later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCards(BuildContext context, WidgetRef ref, List<Program> programs, AppStateData appState) {
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
    final theme = Theme.of(context);
    final isAvailable = rolePrograms.isNotEmpty;
    final hasActiveProgram = appState.hasActiveProgram;
    final isActiveRole = hasActiveProgram && 
        appState.activeProgram?.role == role;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isAvailable && !hasActiveProgram
            ? () => _onRoleSelected(context, ref, role, rolePrograms.first)
            : null,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? info.color.withOpacity(0.1)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  info.icon,
                  size: 32,
                  color: isAvailable
                      ? info.color
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isAvailable && rolePrograms.isNotEmpty) ...[
                      _buildProgramStats(context, rolePrograms.first),
                    ] else ...[
                      Text(
                        'Coming Soon',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isActiveRole) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (hasActiveProgram) ...[
                Icon(
                  Icons.lock,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ] else if (isAvailable) ...[
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramStats(BuildContext context, Program program) {
    final theme = Theme.of(context);
    final totalSessions = program.weeks.fold<int>(
      0, (sum, week) => sum + week.sessions.length,
    );

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '5 weeks',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.fitness_center,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '$totalSessions sessions',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _onRoleSelected(BuildContext context, WidgetRef ref, UserRole role, Program program) {
    // Navigate to program detail screen
    context.go('/programs/${program.id}');
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
