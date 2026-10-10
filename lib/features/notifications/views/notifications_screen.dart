import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mockNotifications = [
      {
        'title': 'Exam Schedule Update',
        'body': 'Dr. Ramanathan posted the end-semester exam schedule for Nov/Dec 2024.',
        'time': '2 hours ago',
        'icon': Icons.campaign_rounded,
        'color': AppColors.primary,
      },
      {
        'title': 'Doubt Answered',
        'body': 'Prof. Vignesh answered your doubt on Operating Systems Deadlocks.',
        'time': '5 hours ago',
        'icon': Icons.quiz_rounded,
        'color': AppColors.info,
      },
      {
        'title': 'Event Reminder',
        'body': 'Machine Learning Vision Transformers workshop starts in 2 days.',
        'time': '1 day ago',
        'icon': Icons.event_available_rounded,
        'color': AppColors.success,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: mockNotifications.length,
        separatorBuilder: (_, __) => AppSpacing.verticalSm,
        itemBuilder: (context, index) {
          final notif = mockNotifications[index];
          return AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (notif['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notif['icon'] as IconData,
                    color: notif['color'] as Color,
                    size: 20,
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notif['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            notif['time'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        notif['body'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
