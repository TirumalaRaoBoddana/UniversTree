import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_avatar.dart';
import '../../../widgets/app_card.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mockChats = [
      {
        'name': 'CSE 2022-2026 Batch Official',
        'type': 'Department Group',
        'message': 'Prof. Vignesh: Class test postponed to Friday.',
        'time': '10:42 AM',
        'unread': 3,
      },
      {
        'name': 'Rotaract Club Announcements',
        'type': 'Club Channel',
        'message': 'Blood donation camp banner uploaded.',
        'time': 'Yesterday',
        'unread': 0,
      },
      {
        'name': 'Priya M. (ECE)',
        'type': 'Direct Message',
        'message': 'Hey, do you have the DSP unit 3 notes?',
        'time': '2 days ago',
        'unread': 1,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Top Info Card
        AppCard(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.tenantBadgeBg,
          child: Row(
            children: [
              const Icon(Icons.forum_rounded, color: AppColors.primary, size: 28),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Campus Messaging Hub',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Isolated strictly to CEG Campus verified students & faculty.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        AppSpacing.verticalLg,

        Text(
          'Active Chats & Channels',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),

        AppSpacing.verticalMd,

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockChats.length,
          separatorBuilder: (_, __) => AppSpacing.verticalSm,
          itemBuilder: (context, index) {
            final chat = mockChats[index];
            final unread = chat['unread'] as int;

            return AppCard(
              child: Row(
                children: [
                  AppAvatar(
                    name: chat['name'] as String,
                    radius: 20,
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                chat['name'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            Text(
                              chat['time'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalXs,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                chat['message'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            if (unread > 0)
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unread',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
          },
        ),
      ],
    );
  }
}
