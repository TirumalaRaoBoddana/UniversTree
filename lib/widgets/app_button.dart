import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonHeight = height ?? 50.0;

    Widget childContent;

    if (isLoading) {
      childContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary
                ? Colors.white
                : (isDark ? AppColors.primaryLight : AppColors.primary),
          ),
        ),
      );
    } else {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 19),
            AppSpacing.horizontalSm,
          ],
          Flexible( // <-- Added Flexible to allow the text to shrink
            child: Text(
              label,
              maxLines: 1, // <-- Prevents multi-line wrapping
              overflow: TextOverflow.ellipsis, // <-- Adds '...' if too long
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      );
    }

    Widget buttonWidget;

    switch (variant) {
      case AppButtonVariant.primary:
        final bool enabled = !isLoading && onPressed != null;
        buttonWidget = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: enabled
                ? const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: enabled ? null : (isDark ? Colors.white12 : AppColors.borderLight),
            boxShadow: enabled
                ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: enabled ? Colors.white : (isDark ? Colors.white38 : AppColors.textMutedLight),
                      fontWeight: FontWeight.w700,
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        color: enabled ? Colors.white : (isDark ? Colors.white38 : AppColors.textMutedLight),
                      ),
                      child: childContent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        break;

      case AppButtonVariant.secondary:
        buttonWidget = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.tenantBadgeBg,
            foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
            elevation: 0,
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: childContent,
        );
        break;

      case AppButtonVariant.outline:
        buttonWidget = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            side: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.16) : AppColors.borderLight,
              width: 1.2,
            ),
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: childContent,
        );
        break;

      case AppButtonVariant.text:
        buttonWidget = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: childContent,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }

    return buttonWidget;
  }
}