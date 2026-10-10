import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routing/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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

          final maxContentWidth = isDesktop
              ? 1180.0
              : isTablet
              ? 850.0
              : 560.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              _RoleSelectionBackground(
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
                        maxWidth: maxContentWidth,
                        minHeight: math.max(
                          0,
                          height - (isLandscape ? 40 : 56),
                        ),
                      ),
                      child: Column(
                        children: [
                          _TopBar(
                            isDark: isDark,
                          ),

                          SizedBox(
                            height: isSmallPhone
                                ? 28
                                : isPhone
                                ? 38
                                : 48,
                          ),

                          _Header(
                            isDark: isDark,
                            isSmallPhone: isSmallPhone,
                            isDesktop: isDesktop,
                          ),

                          SizedBox(
                            height: isSmallPhone
                                ? 28
                                : isPhone
                                ? 36
                                : 46,
                          ),

                          _RoleGrid(
                            isDark: isDark,
                            isPhone: isPhone,
                            isTablet: isTablet,
                            isDesktop: isDesktop,
                          ),
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

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
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
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  final bool isSmallPhone;
  final bool isDesktop;

  const _Header({
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
      children: [
        Text(
          'How will you use Universtree?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallPhone
                ? 23
                : isDesktop
                ? 32
                : 27,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: titleColor,
          ),
        ),

        const SizedBox(height: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 620,
          ),
          child: Text(
            'Choose the role that best describes your institutional affiliation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallPhone ? 12 : 13.5,
              height: 1.5,
              color: subtitleColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ROLE GRID
// ─────────────────────────────────────────────

class _RoleGrid extends StatelessWidget {
  final bool isDark;
  final bool isPhone;
  final bool isTablet;
  final bool isDesktop;

  const _RoleGrid({
    required this.isDark,
    required this.isPhone,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final roles = [
      _RoleData(
        title: 'Student',
        subtitle: 'Campus Community',
        description:
        'Access academics, PYQs, campus feed, events, and student doubts.',
        icon: Icons.school_rounded,
        onTap: () => context.push(
          AppRoutes.studentOnboarding,
        ),
      ),
      _RoleData(
        title: 'Faculty',
        subtitle: 'Academic Staff',
        description:
        'Teach, publish notes, answer student doubts, and manage subjects.',
        icon: Icons.person_search_rounded,
        onTap: () => context.push(
          AppRoutes.facultyOnboarding,
        ),
      ),
      _RoleData(
        title: 'College Administrator',
        subtitle: 'Institutional Officer',
        description:
        'Register and manage your institution, departments, and faculty.',
        icon: Icons.domain_add_rounded,
        onTap: () => context.push(
          AppRoutes.collegeAdminOnboarding,
        ),
      ),
    ];

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < roles.length; i++) ...[
            Expanded(
              child: _RoleCard(
                data: roles[i],
                isDark: isDark,
                compact: true,
              ),
            ),
            if (i != roles.length - 1)
              const SizedBox(width: 18),
          ],
        ],
      );
    }

    if (isTablet) {
      return Wrap(
        spacing: 18,
        runSpacing: 18,
        alignment: WrapAlignment.center,
        children: [
          for (final role in roles)
            SizedBox(
              width: 390,
              child: _RoleCard(
                data: role,
                isDark: isDark,
                compact: false,
              ),
            ),
        ],
      );
    }

    return Column(
      children: [
        for (int i = 0; i < roles.length; i++) ...[
          _RoleCard(
            data: roles[i],
            isDark: isDark,
            compact: false,
          ),
          if (i != roles.length - 1)
            const SizedBox(height: 16),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ROLE CARD
// ─────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final _RoleData data;
  final bool isDark;
  final bool compact;

  const _RoleCard({
    required this.data,
    required this.isDark,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor =
    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final secondaryColor =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0);

    final arrowColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : const Color(0xFF475569);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: EdgeInsets.all(
            compact ? 24 : 22,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.035)
                : Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: compact
              ? _DesktopCardContent(
            data: data,
            titleColor: titleColor,
            secondaryColor: secondaryColor,
            arrowColor: arrowColor,
          )
              : _MobileCardContent(
            data: data,
            titleColor: titleColor,
            secondaryColor: secondaryColor,
            arrowColor: arrowColor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MOBILE / TABLET CARD CONTENT
// ─────────────────────────────────────────────

class _MobileCardContent extends StatelessWidget {
  final _RoleData data;
  final Color titleColor;
  final Color secondaryColor;
  final Color arrowColor;

  const _MobileCardContent({
    required this.data,
    required this.titleColor,
    required this.secondaryColor,
    required this.arrowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoleIcon(
          icon: data.icon,
        ),

        const SizedBox(width: 17),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                    color: arrowColor,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                data.subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                data.description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DESKTOP CARD CONTENT
// ─────────────────────────────────────────────

class _DesktopCardContent extends StatelessWidget {
  final _RoleData data;
  final Color titleColor;
  final Color secondaryColor;
  final Color arrowColor;

  const _DesktopCardContent({
    required this.data,
    required this.titleColor,
    required this.secondaryColor,
    required this.arrowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _RoleIcon(
              icon: data.icon,
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: arrowColor,
            ),
          ],
        ),

        const SizedBox(height: 26),

        Text(
          data.title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          data.subtitle,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),

        const SizedBox(height: 13),

        Text(
          data.description,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.55,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ROLE ICON
// ─────────────────────────────────────────────

class _RoleIcon extends StatelessWidget {
  final IconData icon;

  const _RoleIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        size: 25,
        color: AppColors.primary,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

class _RoleData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────
// BACKGROUND
// ─────────────────────────────────────────────

class _RoleSelectionBackground extends StatelessWidget {
  final bool isDark;

  const _RoleSelectionBackground({
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
            top: -170,
            right: -130,
            child: _BackgroundGlow(
              size: 420,
            ),
          ),
          Positioned(
            bottom: -190,
            left: -150,
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
// CAMPUS NETWORK DECORATION
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
      Offset(size.width * 0.04, size.height * 0.18),
      Offset(size.width * 0.14, size.height * 0.10),
      Offset(size.width * 0.91, size.height * 0.14),
      Offset(size.width * 0.97, size.height * 0.27),
      Offset(size.width * 0.04, size.height * 0.80),
      Offset(size.width * 0.15, size.height * 0.91),
      Offset(size.width * 0.89, size.height * 0.82),
      Offset(size.width * 0.78, size.height * 0.94),
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