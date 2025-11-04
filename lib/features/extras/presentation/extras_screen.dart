import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';

class ExtrasScreen extends ConsumerStatefulWidget {
  const ExtrasScreen({super.key});

  @override
  ConsumerState<ExtrasScreen> createState() => _ExtrasScreenState();
}

class _ExtrasScreenState extends ConsumerState<ExtrasScreen> {
  ExtraType? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extras'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: _selectedCategory == null
          ? _buildCategorySelection(context)
          : _buildCategoryContent(context, _selectedCategory!),
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Boost Your Training',
            subtitle: 'Optional content to enhance your hockey skills',
            icon: Icons.flash_on,
          ),
          const SizedBox(height: 32),
          Text(
            'Choose a Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            title: 'Express Workouts',
            subtitle: '15-20 minute circuits',
            description: 'Quick training sessions when time is limited',
            icon: Icons.timer,
            color: Colors.orange,
            category: ExtraType.expressWorkout,
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            title: 'Bonus Challenges',
            subtitle: 'Special achievement goals',
            description: 'Complete unique challenges to earn bonus XP',
            icon: Icons.emoji_events,
            color: Colors.amber,
            category: ExtraType.bonusChallenge,
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            title: 'Mobility & Recovery',
            subtitle: 'Stretching and flexibility',
            description: 'Essential mobility work for injury prevention',
            icon: Icons.self_improvement,
            color: Colors.green,
            category: ExtraType.mobilityRecovery,
          ),
          const SizedBox(height: 100), // Bottom padding for nav bar
        ],
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required ExtraType category,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                            height: 1.4,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent(BuildContext context, ExtraType category) {
    return Column(
      children: [
        _buildCategoryHeader(context, category),
        Expanded(
          child: _buildExtrasList(context, category),
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(BuildContext context, ExtraType category) {
    final categoryInfo = _getCategoryInfo(category);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: categoryInfo.color.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _selectedCategory = null),
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: categoryInfo.color.withOpacity(0.15),
                foregroundColor: categoryInfo.color,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryInfo.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: categoryInfo.color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                categoryInfo.icon,
                size: 28,
                color: categoryInfo.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryInfo.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categoryInfo.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: categoryInfo.color,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtrasList(BuildContext context, ExtraType category) {
    AsyncValue<List<ExtraItem>> extrasAsync;
    
    switch (category) {
      case ExtraType.expressWorkout:
        extrasAsync = ref.watch(expressWorkoutsProvider);
        break;
      case ExtraType.bonusChallenge:
        extrasAsync = ref.watch(bonusChallengesProvider);
        break;
      case ExtraType.mobilityRecovery:
        extrasAsync = ref.watch(mobilityRecoveryProvider);
        break;
    }

    return extrasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load content',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  switch (category) {
                    case ExtraType.expressWorkout:
                      ref.invalidate(expressWorkoutsProvider);
                      break;
                    case ExtraType.bonusChallenge:
                      ref.invalidate(bonusChallengesProvider);
                      break;
                    case ExtraType.mobilityRecovery:
                      ref.invalidate(mobilityRecoveryProvider);
                      break;
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (extras) => extras.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No extras available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: extras.length,
              itemBuilder: (context, index) => _ExtraCard(
                extra: extras[index],
              ),
            ),
    );
  }

  _CategoryInfo _getCategoryInfo(ExtraType category) {
    switch (category) {
      case ExtraType.expressWorkout:
        return _CategoryInfo(
          title: 'Express Workouts',
          subtitle: '15-20 minute circuits',
          icon: Icons.timer,
          color: Colors.orange,
        );
      case ExtraType.bonusChallenge:
        return _CategoryInfo(
          title: 'Bonus Challenges',
          subtitle: 'Special achievement goals',
          icon: Icons.emoji_events,
          color: Colors.amber,
        );
      case ExtraType.mobilityRecovery:
        return _CategoryInfo(
          title: 'Mobility & Recovery',
          subtitle: 'Stretching and flexibility',
          icon: Icons.self_improvement,
          color: Colors.green,
        );
    }
  }
}

class _CategoryInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _CategoryInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
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
