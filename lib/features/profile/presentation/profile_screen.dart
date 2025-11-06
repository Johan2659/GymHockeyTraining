import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/services/logger_service.dart';
import '../../../app/theme.dart';
import '../../application/app_state_provider.dart';
import '../../auth/application/auth_controller.dart';

/// Step 12 — Profile/MenuScreen with comprehensive user settings - Hockey Gym V2
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final authUserAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: AppTextStyles.subtitle,
        ),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: authUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: AppTheme.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Error loading profile: $error',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(userProfileProvider);
                  ref.refresh(currentUserProfileProvider);
                },
                child: Text(
                  'Retry',
                  style: AppTextStyles.button,
                ),
              ),
            ],
          ),
        ),
        data: (authUser) {
          return profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (profile) => _buildProfileContent(context, authUser, profile),
          );
        },
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      setState(() => _isLoading = true);
      
      try {
        final authController = ref.read(authControllerProvider.notifier);
        final success = await authController.logout();
        
        if (success && context.mounted) {
          LoggerService.instance.info('Logout successful, clearing app state',
              source: 'ProfileScreen');
          
          // Invalidate all app state providers to clear cached data
          ref.invalidate(progressEventsProvider);
          ref.invalidate(programStateProvider);
          ref.invalidate(userProfileProvider);
          ref.invalidate(performanceAnalyticsProvider);
          
          // Invalidate auth providers
          ref.invalidate(currentAuthUserProvider);
          ref.invalidate(isUserLoggedInProvider);
          ref.invalidate(currentUserProfileProvider);
          
          // Small delay to ensure state is cleared
          await Future.delayed(const Duration(milliseconds: 50));
          
          if (context.mounted) {
            // Navigate to auth welcome - router should keep us there since we're logged out
            context.go('/auth/welcome');
            
            LoggerService.instance.info('Navigated to auth welcome',
                source: 'ProfileScreen');
          }
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed')),
          );
          setState(() => _isLoading = false);
        }
      } catch (e, stackTrace) {
        LoggerService.instance.error('Error during logout',
            source: 'ProfileScreen', error: e, stackTrace: stackTrace);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout error occurred')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildProfileContent(BuildContext context, UserProfile? authUser, Profile? profile) {
    // Use safe defaults for nullable fields
    final username = authUser?.username ?? 'User';
    // Convert PlayerRole to UserRole for display
    final userRole = profile?.role ?? _playerRoleToUserRole(authUser?.role ?? PlayerRole.forward);
    final language = profile?.language ?? 'English';
    final units = profile?.units ?? 'kg';
    final theme = profile?.theme ?? 'dark';

    return SingleChildScrollView(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with username
          Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: AppTextStyles.titleL.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _getRoleDisplayName(userRole),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hockey Training',
                          style: AppTextStyles.small.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Settings Section
          Text(
            'Settings',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm + 4),

          // Role Selection
          _buildSettingCard(
            title: 'Role',
            subtitle: _getRoleDisplayName(userRole),
            icon: Icons.sports_hockey,
            onTap: () => _showRoleSelector(context, userRole),
          ),

          // Units Selection
          _buildSettingCard(
            title: 'Units',
            subtitle: units,
            icon: Icons.scale,
            onTap: () => _showUnitsSelector(context, units),
          ),

          // Language Selection
          _buildSettingCard(
            title: 'Language',
            subtitle: language,
            icon: Icons.language,
            onTap: () => _showLanguageSelector(context, language),
          ),

          // Theme Selection
          _buildSettingCard(
            title: 'Theme',
            subtitle: _getThemeDisplayName(theme),
            icon: Icons.palette,
            onTap: () => _showThemeSelector(context, theme),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Actions Section
          Text(
            'Actions',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm + 4),

          // Export Logs Button
          _buildActionCard(
            title: 'Export Logs',
            subtitle: 'Download training data as JSON file',
            icon: Icons.download,
            color: Colors.blue,
            onTap: _isLoading ? null : () => _exportLogs(),
          ),

          // Delete Account Button
          _buildActionCard(
            title: 'Delete Account',
            subtitle: 'Permanently delete all data (cannot be undone)',
            icon: Icons.delete_forever,
            color: Colors.red,
            onTap: _isLoading ? null : () => _deleteAccount(),
          ),

          // Extra bottom padding to clear the bottom navigation bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.small.copyWith(
            color: Colors.grey[400],
          ),
        ),
        trailing:
            Icon(Icons.chevron_right, color: AppTheme.primaryColor, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            color: color.withOpacity(0.2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.small.copyWith(
            fontSize: 11,
            color: Colors.grey[400],
          ),
        ),
        trailing: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.chevron_right, color: color, size: 20),
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }

  Future<void> _showRoleSelector(
      BuildContext context, UserRole currentRole) async {
    final newRole = await showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values
              .map((role) => RadioListTile<UserRole>(
                    title: Text(_getRoleDisplayName(role)),
                    subtitle: Text(_getRoleDescription(role)),
                    value: role,
                    groupValue: currentRole,
                    onChanged: (value) => Navigator.pop(context, value),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newRole != null && newRole != currentRole) {
      await ref.read(updateRoleActionProvider(newRole).future);
    }
  }

  Future<void> _showUnitsSelector(
      BuildContext context, String currentUnits) async {
    const units = ['kg', 'lbs'];
    final newUnits = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: units
              .map((unit) => RadioListTile<String>(
                    title: Text(unit.toUpperCase()),
                    subtitle: Text(unit == 'kg' ? 'Kilograms' : 'Pounds'),
                    value: unit,
                    groupValue: currentUnits,
                    onChanged: (value) => Navigator.pop(context, value),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newUnits != null && newUnits != currentUnits) {
      await ref.read(updateUnitsActionProvider(newUnits).future);
    }
  }

  Future<void> _showLanguageSelector(
      BuildContext context, String currentLanguage) async {
    const languages = ['English', 'French', 'Spanish', 'German'];
    final newLanguage = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map((language) => RadioListTile<String>(
                    title: Text(language),
                    value: language,
                    groupValue: currentLanguage,
                    onChanged: (value) => Navigator.pop(context, value),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newLanguage != null && newLanguage != currentLanguage) {
      await ref.read(updateLanguageActionProvider(newLanguage).future);
    }
  }

  Future<void> _showThemeSelector(
      BuildContext context, String currentTheme) async {
    const themes = ['light', 'dark', 'system'];
    final newTheme = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes
              .map((theme) => RadioListTile<String>(
                    title: Text(_getThemeDisplayName(theme)),
                    value: theme,
                    groupValue: currentTheme,
                    onChanged: (value) => Navigator.pop(context, value),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newTheme != null && newTheme != currentTheme) {
      await ref.read(updateThemeActionProvider(newTheme).future);
    }
  }

  Future<void> _exportLogs() async {
    logInfo('User initiated log export');
    setState(() => _isLoading = true);

    try {
      final filePath = await ref.read(exportLogsActionProvider.future);
      if (filePath != null) {
        logInfo('Log export successful', metadata: {'filePath': filePath});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logs exported to: ${filePath.split('/').last}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Copy Path',
                onPressed: () {
                  // Could add clipboard functionality here if needed
                },
              ),
            ),
          );
        }
      } else {
        logWarning('Log export failed - no file path returned');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to export logs'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      logError('Log export failed with exception',
          error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export logs'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This will permanently delete ALL your data including:\n\n'
          '• Training progress\n'
          '• Profile settings\n'
          '• All workout history\n\n'
          'This action CANNOT be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Second confirmation
      final doubleConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Final Confirmation'),
          content: const Text(
            'This is your FINAL warning. Are you absolutely sure you want to '
            'delete your account and all data?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, Delete Everything'),
            ),
          ],
        ),
      );

      if (doubleConfirmed == true) {
        setState(() => _isLoading = true);

        try {
          final success = await ref.read(deleteAccountActionProvider.future);
          if (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate back to main screen or login
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to delete account'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  // Helper methods
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.attacker:
        return Icons.sports_hockey;
      case UserRole.defender:
        return Icons.shield;
      case UserRole.goalie:
        return Icons.sports;
      case UserRole.referee:
        return Icons.sports_soccer;
    }
  }

  String _getRoleDisplayName(UserRole role) {
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
        return 'Focus on offensive skills and scoring';
      case UserRole.defender:
        return 'Focus on defensive positioning and tactics';
      case UserRole.goalie:
        return 'Focus on goaltending techniques';
      case UserRole.referee:
        return 'Focus on officiating and game management';
    }
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light Theme';
      case 'dark':
        return 'Dark Theme';
      case 'system':
        return 'System Default';
      default:
        return theme;
    }
  }

  // Convert PlayerRole to UserRole for display
  UserRole _playerRoleToUserRole(PlayerRole role) {
    switch (role) {
      case PlayerRole.forward:
        return UserRole.attacker;
      case PlayerRole.defence:
        return UserRole.defender;
      case PlayerRole.goalie:
        return UserRole.goalie;
      case PlayerRole.referee:
        return UserRole.referee;
    }
  }
}
