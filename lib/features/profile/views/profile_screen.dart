import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/user_model.dart';
import '../../../models/tenant_context.dart';
import '../../../repositories/auth_repository.dart';
import '../../../routing/app_routes.dart';
import '../../../widgets/app_avatar.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/tenant_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepository = MockAuthRepository();
  UserModel? _user;
  TenantContext? _tenant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _authRepository.getCurrentUser();
    final tenant = await _authRepository.getTenantContext();
    if (mounted) {
      setState(() {
        _user = user;
        _tenant = tenant;
        _isLoading = false;
      });
    }
  }

  void _onSignOut() async {
    await _authRepository.signOut();
    if (mounted) {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Digital ID & Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Digital Campus ID Card
                AppCard(
                  backgroundColor: isDark ? AppColors.surfaceDark : AppColors.cardLight,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                              AppSpacing.horizontalXs,
                              Text(
                                _tenant?.collegeShortName ?? 'CEG',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const TenantBadge(
                            collegeShortName: 'Verified Student',
                            visibility: 'global',
                            compact: true,
                          ),
                        ],
                      ),
                      AppSpacing.verticalLg,
                      AppAvatar(
                        name: _user?.displayName ?? 'Student',
                        imageUrl: _user?.avatarUrl,
                        radius: 36,
                        showVerifiedBadge: true,
                      ),
                      AppSpacing.verticalMd,
                      Text(
                        _user?.displayName ?? 'Aditya Kumar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        _user?.email ?? 'student@ceg.annauniv.edu',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      AppSpacing.verticalLg,
                      const Divider(),
                      AppSpacing.verticalMd,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildIdDetail('Department', _user?.department ?? 'CSE', isDark),
                          _buildIdDetail('Year', 'Year ${_user?.academicYear ?? 3}', isDark),
                          _buildIdDetail('Tenant ID', _user?.tenantId ?? 'ceg_main', isDark),
                        ],
                      ),
                    ],
                  ),
                ),

                AppSpacing.verticalLg,

                // Institutional Context Info Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tenant Isolation & Identity Info',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.verticalSm,
                      _buildInfoRow('University', 'Anna University', isDark),
                      _buildInfoRow('College', _tenant?.collegeName ?? 'College of Engineering, Guindy', isDark),
                      _buildInfoRow('Domain', 'ceg.annauniv.edu', isDark),
                      _buildInfoRow('Verification Status', 'Institutional Domain Verified ✓', isDark),
                    ],
                  ),
                ),

                AppSpacing.verticalLg,

                AppButton(
                  label: 'Sign Out',
                  icon: Icons.logout_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: _onSignOut,
                ),
              ],
            ),
    );
  }

  Widget _buildIdDetail(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        AppSpacing.verticalXs,
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
