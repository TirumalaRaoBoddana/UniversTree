import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../repositories/auth_repository.dart';
import '../../../routing/app_routes.dart';

class FacultyOnboardingScreen extends StatefulWidget {
  const FacultyOnboardingScreen({super.key});

  @override
  State<FacultyOnboardingScreen> createState() => _FacultyOnboardingScreenState();
}

class _FacultyOnboardingScreenState extends State<FacultyOnboardingScreen> {
  final AuthRepository _authRepository = MockAuthRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _deptController = TextEditingController(text: 'CSE');
  final TextEditingController _designationController = TextEditingController(text: 'Assistant Professor');
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _onRegisterFaculty() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.registerFacultyRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        department: _deptController.text.trim(),
        designation: _designationController.text.trim(),
      );

      if (mounted) {
        context.go(AppRoutes.facultyVerificationPending);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(title: const Text('Faculty Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faculty Registration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              'Your institutional identity will be verified by your College Administrator.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalLg,

            AppTextField(
              controller: _nameController,
              label: 'Full Name with Title',
              hint: 'Dr. R. Ramanathan',
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            AppSpacing.verticalMd,

            AppTextField(
              controller: _emailController,
              label: 'Faculty Institutional Email',
              hint: 'ramanathan@ceg.annauniv.edu',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            AppSpacing.verticalMd,

            AppTextField(
              controller: _deptController,
              label: 'Department',
              hint: 'Computer Science and Engineering',
              prefixIcon: const Icon(Icons.domain_rounded),
            ),
            AppSpacing.verticalMd,

            AppTextField(
              controller: _designationController,
              label: 'Designation',
              hint: 'Professor / Head of Department',
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            AppSpacing.verticalMd,

            AppTextField(
              controller: _passwordController,
              label: 'Password',
              hint: '••••••••',
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
            ),
            AppSpacing.verticalLg,

            AppButton(
              label: 'Submit for Verification',
              isFullWidth: true,
              isLoading: _isLoading,
              onPressed: _onRegisterFaculty,
            ),
          ],
        ),
      ),
    );
  }
}
