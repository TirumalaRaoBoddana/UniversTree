import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool? enabled;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final dynamic prefixIcon;
  final dynamic suffixIcon;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;
  final TextAlign textAlign;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.enabled,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.textAlign = TextAlign.start,
  });

  Widget? _buildIcon(dynamic icon, Color defaultColor) {
    if (icon == null) return null;
    if (icon is Widget) return icon;
    if (icon is IconData) return Icon(icon, size: 20, color: defaultColor);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalXs,
        ],
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          textAlign: textAlign,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
            errorText: errorText,
            // Custom Amber Error Text
            errorStyle: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: _buildIcon(prefixIcon, iconColor),
            suffixIcon: _buildIcon(suffixIcon, iconColor),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            // Custom Amber Error Borders
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(
                color: AppColors.warning,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: const BorderSide(
                color: AppColors.warning,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}