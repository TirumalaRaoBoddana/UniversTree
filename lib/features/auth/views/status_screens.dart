import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../routing/app_routes.dart';

class FacultyPendingScreen extends StatelessWidget {
  const FacultyPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 48,
                  color: AppColors.warning,
                ),
              ),
              AppSpacing.verticalLg,
              const Text(
                'Faculty Verification Pending',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSm,
              const Text(
                'Your faculty registration has been submitted. Your College Administrator must verify your account before you can access the faculty academic workspace.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
              AppSpacing.verticalXl,
              AppButton(
                label: 'Check Verification Status',
                icon: Icons.refresh_rounded,
                onPressed: () => context.go(AppRoutes.home),
              ),
              AppSpacing.verticalMd,
              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.text,
                onPressed: () => context.go(AppRoutes.welcome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollegePendingScreen extends StatelessWidget {
  const CollegePendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  size: 48,
                  color: AppColors.info,
                ),
              ),
              AppSpacing.verticalLg,
              const Text(
                'Institution Review Pending',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSm,
              const Text(
                'Your college registration request is under review by the Universtree Platform Governance team. You will be notified once domain whitelisting is complete.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
              AppSpacing.verticalXl,
              AppButton(
                label: 'Check Status',
                icon: Icons.refresh_rounded,
                onPressed: () => context.go(AppRoutes.splash),
              ),
              AppSpacing.verticalMd,
              AppButton(
                label: 'Return to Welcome',
                variant: AppButtonVariant.text,
                onPressed: () => context.go(AppRoutes.welcome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollegeRejectedScreen extends StatelessWidget {
  const CollegeRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              AppSpacing.verticalLg,
              const Text(
                'Registration Not Approved',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSm,
              const Text(
                'Your institution registration request could not be verified automatically. Please contact support or resubmit official domain accreditation documents.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
              AppSpacing.verticalXl,
              AppButton(
                label: 'Resubmit Information',
                onPressed: () => context.push(AppRoutes.collegeAdminOnboarding),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountSuspendedScreen extends StatelessWidget {
  const AccountSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              AppSpacing.verticalLg,
              const Text(
                'Account Suspended',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSm,
              const Text(
                'This account has been suspended by your institutional administrator or platform governance. Please contact your college administration.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
              AppSpacing.verticalXl,
              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.outline,
                onPressed: () => context.go(AppRoutes.welcome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
