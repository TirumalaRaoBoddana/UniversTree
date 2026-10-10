import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../repositories/auth_repository.dart';
import '../../../routing/app_routes.dart';

class StudentOnboardingScreen extends StatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  State<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends State<StudentOnboardingScreen> {
  final AuthRepository _authRepository = MockAuthRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() => _emailError = 'Please enter a valid institutional email address.');
      return;
    }

    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    try {
      await _authRepository.registerStudent(
        email: email,
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        collegeDomain: email.split('@').last,
      );

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailError = 'Registration failed. Please check your details.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(title: const Text('Student Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join Your Campus',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              'Enter your official college email address to automatically detect your institution.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalLg,

            AppTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Aditya Kumar',
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            AppSpacing.verticalMd,

            AppTextField(
              controller: _emailController,
              label: 'Institutional Email (.edu / college domain)',
              hint: 'student@ceg.annauniv.edu',
              errorText: _emailError,
              prefixIcon: const Icon(Icons.email_outlined),
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
              label: 'Join Campus Platform',
              isFullWidth: true,
              isLoading: _isLoading,
              onPressed: _onRegister,
            ),
          ],
        ),
      ),
    );
  }
}
