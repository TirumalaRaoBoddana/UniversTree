import 'package:flutter/material.dart';
import '../models/resource_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_card.dart';
import 'tenant_badge.dart';

class ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.onDownload,
  });

  IconData _getFileIcon() {
    switch (resource.type.toLowerCase()) {
      case 'pyqs':
        return Icons.quiz_rounded;
      case 'notes':
        return Icons.menu_book_rounded;
      case 'syllabus':
        return Icons.assignment_outlined;
      case 'lab manuals':
        return Icons.biotech_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Type Icon Container
          Container(
            padding: const EdgeInsets.all(AppSpacing.md - 2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.tenantBadgeBg,
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(
              _getFileIcon(),
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              size: 26,
            ),
          ),
          AppSpacing.horizontalMd,

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Text(
                        'Sem ${resource.semester} • ${resource.subjectCode}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    TenantBadge(
                      collegeShortName: 'CEG',
                      visibility: resource.visibility,
                      compact: true,
                    ),
                  ],
                ),
                AppSpacing.verticalXs,
                Text(
                  resource.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  '${resource.subjectName} • ${resource.uploaderName}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.verticalSm,
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 12, color: AppColors.success),
                    const SizedBox(width: 3),
                    Text(
                      '${resource.upvotes}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    AppSpacing.horizontalMd,
                    const Icon(Icons.download_rounded, size: 12, color: AppColors.info),
                    const SizedBox(width: 3),
                    Text(
                      '${resource.downloadsCount} downloads',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
