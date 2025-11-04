import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Selectable card widget for onboarding screens
class OnboardingSelectableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isCompact;

  const OnboardingSelectableCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isCompact ? 36.0 : 48.0;
    final cardPadding = isCompact ? 16.0 : 20.0;
    final iconSpacing = isCompact ? 12.0 : 16.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: isSelected ? AppTheme.accentColor : AppTheme.onSurfaceColor.withOpacity(0.7),
              ),
              SizedBox(width: iconSpacing),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: isCompact ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.accentColor : AppTheme.onSurfaceColor,
                        ),
                  ),
                  SizedBox(height: isCompact ? 4 : 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: isCompact ? 13 : 14,
                          color: AppTheme.onSurfaceColor.withOpacity(0.7),
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
}

/// Primary CTA button for onboarding screens
class OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const OnboardingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.onPrimaryColor,
          disabledBackgroundColor: AppTheme.surfaceColor,
          disabledForegroundColor: AppTheme.onSurfaceColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimaryColor),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
