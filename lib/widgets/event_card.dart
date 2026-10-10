import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_card.dart';
import 'tenant_badge.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onRsvpToggle;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onRsvpToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('EEE, MMM d • h:mm a');

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Banner or Fallback Header
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.tenantBadgeBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
            ),
            child: Stack(
              children: [
                if (event.bannerUrl != null && event.bannerUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                    child: Image.network(
                      event.bannerUrl!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Center(
                    child: Icon(
                      Icons.event_seat_rounded,
                      size: 48,
                      color: isDark ? AppColors.primaryLight.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: TenantBadge(
                    collegeShortName: 'CEG',
                    visibility: event.visibility,
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Text(
                      event.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event Body Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.verticalSm,
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                    AppSpacing.horizontalXs,
                    Expanded(
                      child: Text(
                        dateFormat.format(event.startTime),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalXs,
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.error),
                    AppSpacing.horizontalXs,
                    Expanded(
                      child: Text(
                        event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${event.rsvpCount} Attending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    InkWell(
                      onTap: onRsvpToggle,
                      borderRadius: AppRadius.borderPill,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: event.isRsvped ? AppColors.success : (isDark ? AppColors.surfaceDark : AppColors.tenantBadgeBg),
                          borderRadius: AppRadius.borderPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              event.isRsvped ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                              size: 14,
                              color: event.isRsvped ? Colors.white : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.isRsvped ? 'RSVP\'d' : 'RSVP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: event.isRsvped ? Colors.white : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
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
