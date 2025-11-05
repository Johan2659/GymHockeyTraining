import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/models.dart';
import '../application/session_preview_model.dart';
import '../application/session_preview_provider.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String programId;
  final String week;
  final String session;

  const SessionDetailScreen({
    super.key,
    required this.programId,
    required this.week,
    required this.session,
  });

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    final weekIndex = int.parse(widget.week);
    final sessionIndex = int.parse(widget.session);
    final sessionAsync = ref.watch(
        resolvedSessionProvider((widget.programId, weekIndex, sessionIndex)));
    final resolvedSession = sessionAsync.valueOrNull;
    final sessionTitle = resolvedSession?.session.title ??
        'Week ${weekIndex + 1}, Session ${sessionIndex + 1}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sessionTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Week ${weekIndex + 1} • Session ${sessionIndex + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 24),
            onPressed: () =>
                _showSessionInfo(context, resolvedSession?.session),
            tooltip: 'Session Info',
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading session...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.red.withOpacity(0.2),
                        Colors.red.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to load session',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (session) => session == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.15),
                              AppTheme.primaryColor.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Session not found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The requested session could not be found.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : _buildSessionContent(context, session),
      ),
    );
  }

  Widget _buildSessionContent(
      BuildContext context, ResolvedSession session) {
    final sessionData = session.session;
    final exercises = session.exercises;

    return Column(
      children: [
        // Header with session overview - Glassmorphism + Hockey lines
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session title with thin accent line
              Row(
                children: [
                  // Very thin vertical accent line
                  Container(
                    width: 2,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sessionData.title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Placeholder warning - glassmorphism
              if (session.hasPlaceholders) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade300,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Some exercises are placeholders and will be updated soon.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade200,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Stats row - clean with thin divider
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Exercises count
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.fitness_center,
                            value: '${exercises.length}',
                            label: 'EXERCISES',
                          ),
                        ),
                        
                        // Very thin vertical divider
                        Container(
                          width: 1,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.primaryColor.withOpacity(0.3),
                                AppTheme.primaryColor.withOpacity(0.5),
                                AppTheme.primaryColor.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        
                        // Duration estimate
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.schedule,
                            value: '~${_estimateDuration(exercises)}',
                            label: 'MINUTES',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Exercise preview list
        Expanded(
          child: exercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primaryColor.withOpacity(0.15),
                                AppTheme.primaryColor.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Session preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Start the session to see exercises',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[400],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _ExercisePreviewCard(
                      exercise: exercise,
                      index: index,
                      isPlaceholder: session.isPlaceholder(exercise),
                    );
                  },
                ),
        ),
        // Start Session button - Clean hockey style
        SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[850]!,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isStarting ? null : _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isStarting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'START THIS SESSION',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startSession() async {
    if (_isStarting) return;

    setState(() {
      _isStarting = true;
    });

    try {
      if (mounted) {
        context.push(
            '/session/${widget.programId}/${widget.week}/${widget.session}/play');
      }
    } catch (error) {
      debugPrint('Failed to start session: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start session: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  int _estimateDuration(List<Exercise> exercises) {
    int totalSeconds = 0;
    for (final exercise in exercises) {
      // Calculate time per set
      final timePerSet = (exercise.duration ?? 0) + (exercise.rest ?? 0);
      totalSeconds += exercise.sets * timePerSet;
    }
    return (totalSeconds / 60).ceil();
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Icon with subtle glow - same as player screen
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.primaryColor.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 26,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          // Value with emphasis
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          // Underline accent - hockey style
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.primaryColor.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionInfo(BuildContext context, Session? session) {
    if (session == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exercises: ${session.blocks.length}'),
            Text('Session ID: ${session.id}'),
            if (session.bonusChallenge.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Bonus: ${session.bonusChallenge}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ExercisePreviewCard extends StatelessWidget {
  const _ExercisePreviewCard({
    required this.exercise,
    required this.index,
    this.isPlaceholder = false,
  });

  final Exercise exercise;
  final int index;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Very thin left accent line - hockey rink inspired
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                    AppTheme.primaryColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          
          // Content with glassmorphism
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              children: [
                // Top thin line
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Main content row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Exercise number badge - hockey puck style
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.2),
                            AppTheme.primaryColor.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Exercise details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise name
                          Text(
                            exercise.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              height: 1.2,
                            ),
                            softWrap: true,
                          ),
                          
                          // Placeholder warning
                          if (isPlaceholder) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 11,
                                  color: Colors.amber.shade300,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Placeholder',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade200,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          const SizedBox(height: 8),
                          
                          // Stats row with thin dot separators
                          Row(
                            children: [
                              if (exercise.sets > 0) ...[
                                _buildStatBadge(
                                  icon: Icons.repeat_rounded,
                                  value: '${exercise.sets}',
                                  label: 'sets',
                                ),
                              ],
                              if (exercise.sets > 0 && exercise.reps > 0) ...[
                                Container(
                                  width: 2,
                                  height: 2,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryColor.withOpacity(0.5),
                                  ),
                                ),
                              ],
                              if (exercise.reps > 0) ...[
                                _buildStatBadge(
                                  icon: Icons.fitness_center,
                                  value: '${exercise.reps}',
                                  label: 'reps',
                                ),
                              ],
                              if (exercise.duration != null && exercise.duration! > 0) ...[
                                Container(
                                  width: 2,
                                  height: 2,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryColor.withOpacity(0.5),
                                  ),
                                ),
                                _buildStatBadge(
                                  icon: Icons.timer_outlined,
                                  value: '${exercise.duration}s',
                                  label: '',
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Bottom thin line
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11,
          color: AppTheme.primaryColor.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          '$value${label.isNotEmpty ? ' $label' : ''}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
