import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';

class ExtrasScreen extends ConsumerWidget {
  const ExtrasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extras'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Boost Your Training',
              subtitle: 'Optional content to enhance your hockey skills',
              icon: Icons.flash_on,
            ),
            SizedBox(height: 24),
            _ExpressWorkoutsSection(),
            SizedBox(height: 24),
            _BonusChallengesSection(),
            SizedBox(height: 24),
            _MobilityRecoverySection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
        ),
      ],
    );
  }
}

class _ExpressWorkoutsSection extends ConsumerWidget {
  const _ExpressWorkoutsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expressWorkoutsAsync = ref.watch(expressWorkoutsProvider);

    return _ExtrasSection(
      title: 'Express Workouts',
      subtitle: '15-20 minute circuits for quick training sessions',
      icon: Icons.timer,
      iconColor: Colors.orange,
      extrasAsync: expressWorkoutsAsync,
    );
  }
}

class _BonusChallengesSection extends ConsumerWidget {
  const _BonusChallengesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonusChallengesAsync = ref.watch(bonusChallengesProvider);

    return _ExtrasSection(
      title: 'Bonus Challenges',
      subtitle: 'Special challenges with XP rewards',
      icon: Icons.emoji_events,
      iconColor: Colors.amber,
      extrasAsync: bonusChallengesAsync,
    );
  }
}

class _MobilityRecoverySection extends ConsumerWidget {
  const _MobilityRecoverySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobilityRecoveryAsync = ref.watch(mobilityRecoveryProvider);

    return _ExtrasSection(
      title: 'Mobility & Recovery',
      subtitle: 'Stretching and recovery routines',
      icon: Icons.self_improvement,
      iconColor: Colors.green,
      extrasAsync: mobilityRecoveryAsync,
    );
  }
}

class _ExtrasSection extends StatelessWidget {
  const _ExtrasSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.extrasAsync,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final AsyncValue<List<ExtraItem>> extrasAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        const SizedBox(height: 12),
        extrasAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load content',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          data: (extras) => Column(
            children: extras.map((extra) => _ExtraCard(extra: extra)).toList(),
          ),
        ),
      ],
    );
  }
}

class _ExtraCard extends StatelessWidget {
  const _ExtraCard({required this.extra});

  final ExtraItem extra;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/extras/${extra.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          extra.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          extra.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${extra.xpReward} XP',
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (extra.difficulty != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(extra.difficulty!)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            extra.difficulty!.toUpperCase(),
                            style: TextStyle(
                              color: _getDifficultyColor(extra.difficulty!),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${extra.duration} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${extra.blocks.length} exercises',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
