import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../repositories/auth_repository.dart';
import '../../../routing/app_routes.dart';

class CollegeAdminOnboardingScreen extends StatefulWidget {
  const CollegeAdminOnboardingScreen({super.key});

  @override
  State<CollegeAdminOnboardingScreen> createState() =>
      _CollegeAdminOnboardingScreenState();
}

class _CollegeAdminOnboardingScreenState
    extends State<CollegeAdminOnboardingScreen> {
  final AuthRepository _authRepository = MockAuthRepository();

  final TextEditingController _instNameController =
  TextEditingController();
  final TextEditingController _shortNameController =
  TextEditingController();
  final TextEditingController _emailController =
  TextEditingController();
  final TextEditingController _domainController =
  TextEditingController();
  final TextEditingController _websiteController =
  TextEditingController();
  final TextEditingController _adminNameController =
  TextEditingController();

  bool _isLoading = false;

  void _onSubmitRegistration() async {
    setState(() => _isLoading = true);

    try {
      await _authRepository.submitCollegeRegistration(
        institutionName: _instNameController.text.trim(),
        shortName: _shortNameController.text.trim(),
        officialEmail: _emailController.text.trim(),
        officialDomain: _domainController.text.trim(),
        officialWebsite: _websiteController.text.trim(),
        campusLocation: 'Main Campus',
        administratorName: _adminNameController.text.trim(),
      );

      if (mounted) {
        context.go(AppRoutes.collegeRegistrationPending);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _instNameController.dispose();
    _shortNameController.dispose();
    _emailController.dispose();
    _domainController.dispose();
    _websiteController.dispose();
    _adminNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final isSmallPhone = width < 360;
          final isPhone = width < 600;
          final isTablet = width >= 600 && width < 1024;
          final isDesktop = width >= 1024;
          final isLandscape = width > height;

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          final horizontalPadding = isSmallPhone
              ? 20.0
              : isPhone
              ? 28.0
              : isTablet
              ? 48.0
              : 64.0;

          final maxWidth = isDesktop
              ? 920.0
              : isTablet
              ? 760.0
              : 560.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              _OnboardingBackground(
                isDark: isDark,
              ),

              const IgnorePointer(
                child: CustomPaint(
                  painter: _CampusNetworkPainter(),
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isLandscape ? 20 : 28,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxWidth,
                        minHeight: math.max(
                          0,
                          height - (isLandscape ? 40 : 56),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TopBar(
                            isDark: isDark,
                          ),

                          SizedBox(
                            height: isSmallPhone
                                ? 26
                                : isPhone
                                ? 34
                                : 42,
                          ),

                          _PageHeader(
                            isDark: isDark,
                            isSmallPhone: isSmallPhone,
                            isDesktop: isDesktop,
                          ),

                          SizedBox(
                            height: isSmallPhone
                                ? 28
                                : isPhone
                                ? 34
                                : 42,
                          ),

                          _RegistrationForm(
                            isDark: isDark,
                            isSmallPhone: isSmallPhone,
                            isDesktop: isDesktop,
                            instNameController: _instNameController,
                            shortNameController: _shortNameController,
                            emailController: _emailController,
                            domainController: _domainController,
                            websiteController: _websiteController,
                            adminNameController: _adminNameController,
                            isLoading: _isLoading,
                            onSubmit: _onSubmitRegistration,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool isDark;

  const _TopBar({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.88)
        : const Color(0xFF334155);

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.pop(),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 23,
                color: iconColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PAGE HEADER
// ─────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final bool isDark;
  final bool isSmallPhone;
  final bool isDesktop;

  const _PageHeader({
    required this.isDark,
    required this.isSmallPhone,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor =
    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final subtitleColor =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small context label
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'COLLEGE ADMINISTRATOR',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.15,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Text(
          'Register Your College / University',
          style: TextStyle(
            fontSize: isSmallPhone
                ? 24
                : isDesktop
                ? 32
                : 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.55,
            color: titleColor,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Bring your digital campus layer to Universtree. Platform governance review is required.',
          style: TextStyle(
            fontSize: isSmallPhone ? 12 : 13.5,
            height: 1.55,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FORM
// ─────────────────────────────────────────────

class _RegistrationForm extends StatelessWidget {
  final bool isDark;
  final bool isSmallPhone;
  final bool isDesktop;

  final TextEditingController instNameController;
  final TextEditingController shortNameController;
  final TextEditingController emailController;
  final TextEditingController domainController;
  final TextEditingController websiteController;
  final TextEditingController adminNameController;

  final bool isLoading;
  final VoidCallback onSubmit;

  const _RegistrationForm({
    required this.isDark,
    required this.isSmallPhone,
    required this.isDesktop,
    required this.instNameController,
    required this.shortNameController,
    required this.emailController,
    required this.domainController,
    required this.websiteController,
    required this.adminNameController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(
          icon: Icons.account_balance_rounded,
          title: 'Institution Details',
          isDark: isDark,
        ),

        const SizedBox(height: 18),

        _Field(
          child: AppTextField(
            controller: instNameController,
            label: 'Official Institution Name',
            hint: 'College of Engineering, Guindy',
            prefixIcon: const Icon(
              Icons.account_balance_rounded,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _Field(
          child: AppTextField(
            controller: shortNameController,
            label: 'Short Name / Abbreviation',
            hint: 'CEG',
            prefixIcon: const Icon(
              Icons.short_text_rounded,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _Field(
          child: AppTextField(
            controller: emailController,
            label: 'Official Administrative Email',
            hint: 'principal@ceg.annauniv.edu',
            prefixIcon: const Icon(
              Icons.mark_email_read_outlined,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _Field(
          child: AppTextField(
            controller: domainController,
            label: 'Institutional Email Domain',
            hint: 'ceg.annauniv.edu',
            prefixIcon: const Icon(
              Icons.domain_verification_rounded,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _Field(
          child: AppTextField(
            controller: websiteController,
            label: 'Official Website URL',
            hint: 'https://ceg.annauniv.edu',
            prefixIcon: const Icon(
              Icons.language_rounded,
            ),
          ),
        ),

        const SizedBox(height: 30),

        _SectionLabel(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Administrator Representative',
          isDark: isDark,
        ),

        const SizedBox(height: 18),

        _Field(
          child: AppTextField(
            controller: adminNameController,
            label: 'Administrator Representative Name',
            hint: 'Dr. S. Meenakshi (Registrar)',
            prefixIcon: const Icon(
              Icons.admin_panel_settings_outlined,
            ),
          ),
        ),

        const SizedBox(height: 32),

        AppButton(
          label: 'Submit Institution for Review',
          isFullWidth: true,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;

  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final mutedColor =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.primary,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : mutedColor.withValues(alpha: 0.16),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FIELD WRAPPER
// ─────────────────────────────────────────────

class _Field extends StatelessWidget {
  final Widget child;

  const _Field({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

// ─────────────────────────────────────────────
// BACKGROUND
// ─────────────────────────────────────────────

class _OnboardingBackground extends StatelessWidget {
  final bool isDark;

  const _OnboardingBackground({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF0B1220),
            const Color(0xFF111827),
            AppColors.primary.withValues(alpha: 0.18),
          ]
              : [
            const Color(0xFFF8FAFC),
            const Color(0xFFEFF6FF),
            AppColors.primary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -180,
            right: -140,
            child: _BackgroundGlow(
              size: 430,
            ),
          ),
          Positioned(
            bottom: -190,
            left: -160,
            child: _BackgroundGlow(
              size: 450,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;

  const _BackgroundGlow({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(
          alpha: 0.045,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NETWORK DECORATION
// ─────────────────────────────────────────────

class _CampusNetworkPainter extends CustomPainter {
  const _CampusNetworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.045)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.075)
      ..style = PaintingStyle.fill;

    final nodes = [
      Offset(size.width * 0.04, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.08),
      Offset(size.width * 0.91, size.height * 0.13),
      Offset(size.width * 0.97, size.height * 0.27),
      Offset(size.width * 0.04, size.height * 0.82),
      Offset(size.width * 0.15, size.height * 0.92),
      Offset(size.width * 0.89, size.height * 0.84),
      Offset(size.width * 0.78, size.height * 0.95),
    ];

    const connections = [
      [0, 1],
      [1, 2],
      [2, 3],
      [0, 4],
      [4, 5],
      [3, 6],
      [6, 7],
      [5, 7],
    ];

    for (final connection in connections) {
      canvas.drawLine(
        nodes[connection[0]],
        nodes[connection[1]],
        linePaint,
      );
    }

    for (final node in nodes) {
      canvas.drawCircle(
        node,
        3,
        nodePaint,
      );

      canvas.drawCircle(
        node,
        7,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.025),
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}