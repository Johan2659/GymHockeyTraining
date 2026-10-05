import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../application/app_state_provider.dart';

/// A focused home screen backed by the existing training repositories.
class ForgeHomeScreen extends ConsumerWidget {
  const ForgeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final paused = ref.watch(sessionInProgressProvider);
    final express = ref.watch(expressWorkoutsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: FilledButton(
              onPressed: () => ref.invalidate(appStateProvider),
              child: const Text('Retry loading your training'),
            ),
          ),
          data: (data) {
            final resume = paused.asData?.value;
            final ready = data.nextSession != null && data.state != null;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
              children: [
                const Text(
                  'HOCKEYFORGE',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Build your\non-ice edge.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your off-ice work starts here.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume != null
                            ? 'READY TO RESUME'
                            : 'YOUR NEXT WORKOUT',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data.activeProgram?.title ?? 'Find your training plan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resume != null
                            ? 'Your saved session is ready to continue.'
                            : ready
                            ? 'Week ${data.state!.currentWeek + 1} · Session ${data.state!.currentSession + 1}'
                            : data.hasActiveProgram
                            ? 'Cycle completed. Choose your next program.'
                            : 'Strength, power and conditioning for hockey.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: paused.isLoading
                              ? null
                              : () {
                                  if (paused.hasError) {
                                    ref.invalidate(sessionInProgressProvider);
                                    return;
                                  }
                                  HapticFeedback.lightImpact();
                                  if (resume != null) {
                                    context.push(
                                      '/session/${resume.programId}/${resume.week}/${resume.session}/play',
                                    );
                                  } else if (ready) {
                                    final s = data.state!;
                                    context.push(
                                      '/session/${s.activeProgramId}/${s.currentWeek}/${s.currentSession}/play',
                                    );
                                  } else {
                                    context.go('/programs');
                                  }
                                },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            paused.hasError
                                ? 'Retry session check'
                                : resume != null
                                ? 'Resume workout'
                                : ready
                                ? 'Start workout'
                                : 'Choose a program',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _Panel(
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: [
                      _Stat(
                        value: '${data.currentStreak}',
                        label: 'Day streak',
                      ),
                      _Stat(
                        value:
                            '${(data.percentCycle.clamp(0, 1) * 100).round()}%',
                        label: 'Program complete',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Short on time?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A focused session. A little more progress.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                express.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => TextButton(
                    onPressed: () => ref.invalidate(expressWorkoutsProvider),
                    child: const Text('Reload express workouts'),
                  ),
                  data: (items) => Column(
                    children: [
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _Panel(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.bolt,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '${item.duration} min',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward,
                                color: AppColors.primary,
                              ),
                              onTap: () => context.push('/extras/${item.id}'),
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
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.hairline),
    ),
    child: child,
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
    ],
  );
}
