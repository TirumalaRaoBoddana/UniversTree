import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    final defaultBorder = Border.all(
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      width: 1,
    );

    final radius = BorderRadius.circular(borderRadius ?? AppRadius.md);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: radius,
            border: border ?? defaultBorder,
          ),
          child: child,
        ),
      ),
    );
  }
}
