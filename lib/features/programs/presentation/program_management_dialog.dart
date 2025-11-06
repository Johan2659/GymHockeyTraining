import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../application/program_management_controller.dart';
import '../../application/app_state_provider.dart';

/// Dialog for managing the current active program
/// Allows users to stop and optionally delete program data
class ProgramManagementDialog extends ConsumerStatefulWidget {
  const ProgramManagementDialog({super.key});

  @override
  ConsumerState<ProgramManagementDialog> createState() =>
      _ProgramManagementDialogState();
}

class _ProgramManagementDialogState
    extends ConsumerState<ProgramManagementDialog> {
  ProgramDeletionOption _selectedOption = ProgramDeletionOption.stopOnly;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentProgramAsync = ref.watch(currentActiveProgramProvider);
    final progressCountAsync = ref.watch(currentProgramProgressCountProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.stop_circle_outlined, color: AppTheme.warning),
          const SizedBox(width: AppSpacing.sm),
          const Text('Stop Training Program'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current program info
            currentProgramAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error loading program info',
                style: TextStyle(color: AppTheme.error),
              ),
              data: (program) => program == null
                  ? const Text('No active program found')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Program:',
                          style: AppTextStyles.small.copyWith(
                                    color: Colors.grey[400],
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          program.title,
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        progressCountAsync.when(
                          loading: () => const Text('Loading progress...'),
                          error: (error, stack) =>
                              const Text('Error loading progress'),
                          data: (count) => Text(
                            '$count progress events recorded',
                            style: AppTextStyles.small.copyWith(
                                      color: Colors.grey[400],
                                    ),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // Options
            Text(
              'What would you like to do?',
              style: AppTextStyles.subtitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm + 4),

            // Option 1: Stop only
            RadioListTile<ProgramDeletionOption>(
              title: const Text('Stop program only'),
              subtitle: const Text('Keep all progress data and statistics'),
              value: ProgramDeletionOption.stopOnly,
              groupValue: _selectedOption,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedOption = value;
                        });
                      }
                    },
              contentPadding: EdgeInsets.zero,
            ),

            // Option 2: Stop and delete progress
            RadioListTile<ProgramDeletionOption>(
              title: const Text('Stop and delete progress'),
              subtitle: const Text('Remove this program\'s workout history'),
              value: ProgramDeletionOption.stopAndDeleteProgress,
              groupValue: _selectedOption,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedOption = value;
                        });
                      }
                    },
              contentPadding: EdgeInsets.zero,
            ),

            // Option 3: Stop and delete everything
            RadioListTile<ProgramDeletionOption>(
              title: const Text('Stop and delete everything'),
              subtitle: const Text('Remove all data for this program'),
              value: ProgramDeletionOption.stopAndDeleteEverything,
              groupValue: _selectedOption,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedOption = value;
                        });
                      }
                    },
              contentPadding: EdgeInsets.zero,
            ),

            if (_selectedOption != ProgramDeletionOption.stopOnly) ...[
              const SizedBox(height: AppSpacing.sm + 4),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 4),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: AppTheme.error.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: AppTheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'This action cannot be undone!',
                        style: AppTextStyles.small.copyWith(
                              color: AppTheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleStopProgram,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedOption == ProgramDeletionOption.stopOnly
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            foregroundColor: _selectedOption == ProgramDeletionOption.stopOnly
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onError,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_getActionButtonText()),
        ),
      ],
    );
  }

  String _getActionButtonText() {
    switch (_selectedOption) {
      case ProgramDeletionOption.stopOnly:
        return 'Stop Program';
      case ProgramDeletionOption.stopAndDeleteProgress:
        return 'Stop & Delete Progress';
      case ProgramDeletionOption.stopAndDeleteEverything:
        return 'Stop & Delete All';
    }
  }

  Future<void> _handleStopProgram() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ProgramManagementService.stopCurrentProgram(
        ref: ref,
        option: _selectedOption,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();

          // Force immediate UI refresh by invalidating the app state provider
          ref.invalidate(appStateProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getSuccessMessage()),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to stop program. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getSuccessMessage() {
    switch (_selectedOption) {
      case ProgramDeletionOption.stopOnly:
        return 'Program stopped. Your progress data has been preserved.';
      case ProgramDeletionOption.stopAndDeleteProgress:
        return 'Program stopped and progress data deleted.';
      case ProgramDeletionOption.stopAndDeleteEverything:
        return 'Program stopped and all data deleted.';
    }
  }
}
