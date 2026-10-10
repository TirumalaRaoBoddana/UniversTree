import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/faculty_request_model.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../routing/app_routes.dart';

class CollegeAdminDashboardScreen extends StatefulWidget {
  const CollegeAdminDashboardScreen({super.key});

  @override
  State<CollegeAdminDashboardScreen> createState() => _CollegeAdminDashboardScreenState();
}

class _CollegeAdminDashboardScreenState extends State<CollegeAdminDashboardScreen> {
  final List<FacultyRequestModel> _facultyRequests = [
    FacultyRequestModel(
      id: 'freq_1',
      facultyUid: 'u_fac_101',
      facultyName: 'Dr. S. Kanthasamy',
      facultyEmail: 'kanthasamy@ceg.annauniv.edu',
      collegeId: 'ceg_main',
      collegeName: 'College of Engineering, Guindy',
      department: 'ECE',
      designation: 'Associate Professor',
      facultyIdNumber: 'CEG-ECE-402',
      status: 'pending',
      submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  void _verifyFaculty(String id) {
    setState(() {
      _facultyRequests.removeWhere((r) => r.id == id);
    });
  }

  void _rejectFaculty(String id) {
    setState(() {
      _facultyRequests.removeWhere((r) => r.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('College Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.go(AppRoutes.welcome),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // College Admin Banner
          AppCard(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.tenantBadgeBg,
            child: Row(
              children: [
                const Icon(Icons.domain_rounded, color: AppColors.primary, size: 32),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'College of Engineering, Guindy',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Institutional Administration & Faculty Verification Portal',
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
            'Pending Faculty Verifications (${_facultyRequests.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),

          AppSpacing.verticalMd,

          if (_facultyRequests.isEmpty)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 32),
                    AppSpacing.verticalSm,
                    Text(
                      'No Pending Faculty Verifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _facultyRequests.length,
              separatorBuilder: (_, __) => AppSpacing.verticalMd,
              itemBuilder: (context, index) {
                final req = _facultyRequests[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            req.facultyName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: AppRadius.borderPill,
                            ),
                            child: const Text(
                              'VERIFICATION PENDING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        '${req.designation} • Dept: ${req.department}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        'Email: ${req.facultyEmail} • Faculty ID: ${req.facultyIdNumber ?? "N/A"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      AppSpacing.verticalLg,
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Verify Faculty',
                              variant: AppButtonVariant.primary,
                              height: 36,
                              onPressed: () => _verifyFaculty(req.id),
                            ),
                          ),
                          AppSpacing.horizontalSm,
                          Expanded(
                            child: AppButton(
                              label: 'Reject',
                              variant: AppButtonVariant.outline,
                              height: 36,
                              onPressed: () => _rejectFaculty(req.id),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
