import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/logger_service.dart';
import '../../../app/theme.dart';
import '../../application/app_state_provider.dart';

/// Step 12 — Profile/MenuScreen with comprehensive user settings
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading profile: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => _buildProfileContent(context, profile),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Profile? profile) {
    // Use safe defaults for nullable fields
    final role = profile?.role ?? UserRole.attacker;
    final language = profile?.language ?? 'English';
    final units = profile?.units ?? 'kg';
    final theme = profile?.theme ?? 'dark';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                    child: Icon(
                      _getRoleIcon(role),
                      size: 24,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getRoleDisplayName(role),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hockey Training Profile',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Settings Section
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Role Selection
          _buildSettingCard(
            title: 'Role',
            subtitle: _getRoleDisplayName(role),
            icon: Icons.sports_hockey,
            onTap: () => _showRoleSelector(context, role),
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

          const SizedBox(height: 24),

          // Actions Section
          Text(
            'Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

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

          const SizedBox(height: 24),
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
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
}
