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
        title: Text('Extras', style: AppTextStyles.subtitle),
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
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Boost Your Training',
            subtitle: 'Optional content to enhance your hockey skills',
            icon: Icons.flash_on,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Choose a Category',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCategoryTile(
            context,
            title: 'Express Workouts',
            subtitle: '15-20 minute circuits',
            description: 'Quick training sessions when time is limited',
            icon: Icons.timer,
            color: AppTheme.inProgress,
            category: ExtraType.expressWorkout,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCategoryTile(
            context,
            title: 'Bonus Challenges',
            subtitle: 'Special achievement goals',
            description: 'Complete unique challenges to earn bonus XP',
            icon: Icons.emoji_events,
            color: Colors.amber,
            category: ExtraType.bonusChallenge,
          ),
          const SizedBox(height: AppSpacing.md),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg - 4),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
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
              const SizedBox(width: AppSpacing.lg - 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm + 2),
                    Text(
                      description,
                      style: AppTextStyles.small.copyWith(
                            height: 1.4,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
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
            const SizedBox(width: AppSpacing.sm + 4),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryInfo.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
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
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryInfo.title,
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categoryInfo.subtitle,
                    style: AppTextStyles.small.copyWith(
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
          padding: AppSpacing.card,
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
                'Failed to load content',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: AppTextStyles.small,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
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
                child: Text('Retry', style: AppTextStyles.button),
              ),
            ],
          ),
        ),
      ),
      data: (extras) => extras.isEmpty
          ? Center(
              child: Padding(
                padding: AppSpacing.card,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AppTheme.grey600,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No extras available',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: AppSpacing.card,
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
          color: AppTheme.inProgress,
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
            const SizedBox(width: AppSpacing.sm + 4),
            Flexible(
              child: Text(
                title,
                style: AppTextStyles.titleL,
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: AppTextStyles.body.copyWith(
                color: AppTheme.grey400,
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      child: InkWell(
        onTap: () => context.push('/extras/${extra.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
        child: Padding(
          padding: AppSpacing.card,
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
                          style: AppTextStyles.body,
                          softWrap: true,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          extra.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppTheme.grey400,
                                  ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                        ),
                        child: Text(
                          '+${extra.xpReward} XP',
                          style: AppTextStyles.small.copyWith(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (extra.difficulty != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(extra.difficulty!)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          child: Text(
                            extra.difficulty!.toUpperCase(),
                            style: AppTextStyles.labelMicro.copyWith(
                              color: _getDifficultyColor(extra.difficulty!),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppTheme.grey400,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${extra.duration} min',
                    style: AppTextStyles.small,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: AppTheme.grey400,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      '${extra.blocks.length} exercises',
                      style: AppTextStyles.small,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
        return AppTheme.success;
      case 'medium':
        return AppTheme.warning;
      case 'hard':
        return AppTheme.danger;
      default:
        return AppTheme.grey500;
    }
  }
}
