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
      body: _buildBody(context, ref, programsAsync, appStateAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Program>> programsAsync,
    AsyncValue<AppStateData> appStateAsync,
  ) {
    // Check if both are loaded - if so, render immediately
    if (programsAsync.hasValue && appStateAsync.hasValue) {
      return _buildProgramsList(
        context,
        ref,
        programsAsync.value!,
        appStateAsync.value!,
      );
    }

    // Show loading only if both are loading
    if (programsAsync.isLoading || appStateAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle errors
    final error = programsAsync.error ?? appStateAsync.error;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load programs',
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[400],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildProgramsList(BuildContext context, WidgetRef ref,
      List<Program> programs, AppStateData appState) {
    if (programs.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, appState),
          const SizedBox(height: AppSpacing.lg),
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
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Select a training program designed for your hockey position',
          style: AppTextStyles.body.copyWith(
                color: Colors.grey[400],
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_hockey,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Programs Available',
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Training programs are currently being loaded. Please try again later.',
              style: AppTextStyles.body.copyWith(
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
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
        borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? info.color.withOpacity(0.2)
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(
                  info.icon,
                  size: 24,
                  color: isAvailable ? info.color : Colors.grey[600],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      info.description,
                      style: AppTextStyles.small,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (isAvailable && rolePrograms.isNotEmpty) ...[
                      _buildProgramStats(context, rolePrograms.first),
                    ] else ...[
                      Text(
                        'Coming Soon',
                        style: AppTextStyles.small.copyWith(
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              if (isActiveRole) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: AppTextStyles.labelXS.copyWith(
                      color: AppTheme.accentColor,
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
      spacing: AppSpacing.sm + 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: Colors.grey[400],
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '5 weeks',
              style: AppTextStyles.small,
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
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$totalSessions sessions',
              style: AppTextStyles.small,
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

  void _resumeActiveProgram(BuildContext context, AppStateData appState) {
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
