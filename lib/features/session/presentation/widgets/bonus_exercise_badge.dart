import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class BonusExerciseBadge extends StatelessWidget {
  const BonusExerciseBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: AppTheme.accentColor,
            size: 16,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            'BONUS',
            style: AppTextStyles.small.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
