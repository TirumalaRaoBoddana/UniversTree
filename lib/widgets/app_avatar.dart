import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final bool showVerifiedBadge;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 20.0,
    this.showVerifiedBadge = false,
  });

  String _getInitials() {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget avatarContent;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.tenantBadgeBg,
      );
    } else {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        child: Text(
          _getInitials(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.8,
          ),
        ),
      );
    }

    if (!showVerifiedBadge) return avatarContent;

    return Stack(
      children: [
        avatarContent,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.info,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}
