import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class TenantBadge extends StatelessWidget {
  final String collegeShortName;
  final String visibility; // 'private' | 'global'
  final bool compact;

  const TenantBadge({
    super.key,
    required this.collegeShortName,
    this.visibility = 'private',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGlobal = visibility.toLowerCase() == 'global';

    final bgColor = isGlobal ? AppColors.globalBadgeBg : AppColors.tenantBadgeBg;
    final textColor = isGlobal ? AppColors.globalBadgeText : AppColors.tenantBadgeText;
    final icon = isGlobal ? Icons.public_rounded : Icons.domain_rounded;
    final label = isGlobal ? 'Global' : collegeShortName;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs + 2 : AppSpacing.sm,
        vertical: compact ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderPill,
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 10 : 12,
            color: textColor,
          ),
          SizedBox(width: compact ? 3 : 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
