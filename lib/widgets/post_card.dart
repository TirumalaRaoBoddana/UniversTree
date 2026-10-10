import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_card.dart';
import 'app_avatar.dart';
import 'tenant_badge.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLikeToggle,
    this.onCommentTap,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header + Tenant Isolation Badge
          Row(
            children: [
              AppAvatar(
                name: post.authorName,
                imageUrl: post.authorAvatar,
                radius: 18,
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        AppSpacing.horizontalXs,
                        Text(
                          '• ${_formatTimeAgo(post.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      post.authorRole,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              TenantBadge(
                collegeShortName: 'CEG',
                visibility: post.visibility,
                compact: true,
              ),
            ],
          ),

          AppSpacing.verticalMd,

          // Post Title & Body Content
          if (post.title != null && post.title!.isNotEmpty) ...[
            Text(
              post.title!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalXs,
          ],

          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),

          // Optional Category Tag
          AppSpacing.verticalSm,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.borderLight.withValues(alpha: 0.5),
              borderRadius: AppRadius.borderSm,
            ),
            child: Text(
              '#${post.category}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ),

          AppSpacing.verticalMd,
          const Divider(height: 1),
          AppSpacing.verticalSm,

          // Footer Actions (Like, Comment, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onLikeToggle,
                    icon: Icon(
                      post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: post.isLiked ? AppColors.error : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      size: 20,
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 6),
                  ),
                  Text(
                    '${post.likeCount}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.horizontalLg,
                  IconButton(
                    onPressed: onCommentTap,
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      size: 19,
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 6),
                  ),
                  Text(
                    '${post.commentCount}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.bookmark_border_rounded,
                size: 20,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
