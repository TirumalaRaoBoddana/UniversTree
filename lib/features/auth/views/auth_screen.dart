import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../routing/app_routes.dart';
import '../../../repositories/auth_repository.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/app_scaffold.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthRepository _authRepository = MockAuthRepository();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your institutional email and password.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final user = await _authRepository.signInWithEmail(email, password);

      if (mounted) {
        setState(() => _isLoading = false);

        if (user.isSuperAdmin) {
          context.go(AppRoutes.platformAdminDashboard);
        } else if (user.isCollegeAdmin) {
          context.go(AppRoutes.collegeAdminDashboard);
        } else if (user.isPending) {
          context.go(AppRoutes.facultyVerificationPending);
        } else {
          context.go(AppRoutes.home);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid credentials. Please check your email and password.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.welcome);
            }
          },
          tooltip: 'Back',
        ),
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(
                  iconSize: 52,
                  fontSize: 26,
                  showTagline: true,
                ),
                AppSpacing.verticalXl,

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                        AppSpacing.horizontalSm,
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 12, color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.verticalLg,
                ],

                AppTextField(
                  controller: _emailController,
                  label: 'Institutional Email',
                  hint: 'student@college.edu',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
                AppSpacing.verticalMd,

                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                ),
                AppSpacing.verticalLg,

                AppButton(
                  label: 'Sign In to Campus',
                  isFullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _onSignIn,
                ),

                AppSpacing.verticalXl,

                // Don't have an account option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.roleSelection),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
