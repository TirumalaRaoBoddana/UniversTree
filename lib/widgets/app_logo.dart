import 'package:flutter/material.dart';
import '../core/config/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showTagline;

  const AppLogo({
    super.key,
    this.iconSize = 36.0,
    this.fontSize = 22.0,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(iconSize * 0.3),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.borderLg,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.account_tree_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        AppSpacing.verticalSm,
        Text(
          'UNIVERSTREE',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        if (showTagline) ...[
          AppSpacing.verticalXs,
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize * 0.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ],
    );
  }
}
