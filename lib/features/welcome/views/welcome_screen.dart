import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_logo.dart';
import '../../../routing/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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

          final horizontalPadding = isSmallPhone
              ? 20.0
              : isPhone
              ? 28.0
              : isTablet
              ? 48.0
              : 64.0;

          final maxContentWidth = isDesktop
              ? 1080.0
              : isTablet
              ? 760.0
              : 440.0;

          final logoSize = isSmallPhone
              ? 52.0
              : isPhone
              ? 62.0
              : isTablet
              ? 74.0
              : 82.0;

          final logoFontSize = isSmallPhone
              ? 24.0
              : isPhone
              ? 28.0
              : isTablet
              ? 32.0
              : 36.0;

          final titleSize = isSmallPhone
              ? 19.0
              : isPhone
              ? 22.0
              : isTablet
              ? 26.0
              : 30.0;

          final descriptionSize = isSmallPhone
              ? 11.5
              : isPhone
              ? 12.5
              : isTablet
              ? 14.0
              : 15.0;

          final verticalScale = isLandscape
              ? 0.65
              : isSmallPhone
              ? 0.82
              : 1.0;

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ============================================================
              // BACKGROUND
              // ============================================================
              _WelcomeBackground(isDark: isDark),

              // ============================================================
              // SUBTLE CAMPUS NETWORK DECORATION
              // ============================================================
              const IgnorePointer(
                child: CustomPaint(
                  painter: _CampusNetworkPainter(),
                ),
              ),

              // ============================================================
              // CONTENT
              // ============================================================
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isLandscape ? 20 : 32,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxContentWidth,
                        minHeight: isLandscape ? 0 : math.max(0, height - 64),
                      ),
                      child: isDesktop
                          ? _DesktopLayout(
                        logoSize: logoSize,
                        logoFontSize: logoFontSize,
                        titleSize: titleSize,
                        descriptionSize: descriptionSize,
                      )
                          : _MobileLayout(
                        logoSize: logoSize,
                        logoFontSize: logoFontSize,
                        titleSize: titleSize,
                        descriptionSize: descriptionSize,
                        verticalScale: verticalScale,
                        isSmallPhone: isSmallPhone,
                        isDark: isDark,
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

// ============================================================================
// MOBILE / TABLET
// ============================================================================

class _MobileLayout extends StatelessWidget {
  final double logoSize;
  final double logoFontSize;
  final double titleSize;
  final double descriptionSize;
  final double verticalScale;
  final bool isSmallPhone;
  final bool isDark;

  const _MobileLayout({
    required this.logoSize,
    required this.logoFontSize,
    required this.titleSize,
    required this.descriptionSize,
    required this.verticalScale,
    required this.isSmallPhone,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ------------------------------------------------------------
        // LOGO
        // ------------------------------------------------------------
        AppLogo(
          iconSize: logoSize,
          fontSize: logoFontSize,
          showTagline: true,
        ),

        SizedBox(height: 28 * verticalScale),

        // ------------------------------------------------------------
        // TITLE
        // ------------------------------------------------------------
        Text(
          'Everything your campus, connected.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.35,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),

        SizedBox(height: 12 * verticalScale),

        // ------------------------------------------------------------
        // DESCRIPTION
        // ------------------------------------------------------------
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 560,
          ),
          child: Text(
            'Connect with your campus community, access academics, '
                'discover events, and stay informed—all in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descriptionSize,
              height: 1.55,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),

        SizedBox(height: 42 * verticalScale),

        // ------------------------------------------------------------
        // ACTIONS
        // ------------------------------------------------------------
        _Actions(
          isDark: isDark,
          isSmallPhone: isSmallPhone,
        ),
      ],
    );
  }
}

// ============================================================================
// DESKTOP
// ============================================================================

class _DesktopLayout extends StatelessWidget {
  final double logoSize;
  final double logoFontSize;
  final double titleSize;
  final double descriptionSize;

  const _DesktopLayout({
    required this.logoSize,
    required this.logoFontSize,
    required this.titleSize,
    required this.descriptionSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ================================================================
        // LEFT
        // ================================================================
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(right: 70),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppLogo(
                  iconSize: logoSize,
                  fontSize: logoFontSize,
                  showTagline: true,
                ),
                const SizedBox(height: 34),
                Text(
                  'Everything your campus, connected.',
                  style: TextStyle(
                    fontSize: titleSize,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Connect with your campus community, access academics, '
                      'discover events, and stay informed—all in one place.',
                  style: TextStyle(
                    fontSize: descriptionSize,
                    height: 1.6,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ================================================================
        // RIGHT — ACTIONS ONLY
        // ================================================================
        Expanded(
          flex: 4,
          child: _Actions(
            isDark: isDark,
            isSmallPhone: false,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ACTION BUTTONS
// ============================================================================

class _Actions extends StatelessWidget {
  final bool isDark;
  final bool isSmallPhone;

  const _Actions({
    required this.isDark,
    required this.isSmallPhone,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor =
    isDark ? Colors.white.withValues(alpha: 0.88) : const Color(0xFF334155);

    final mutedTextColor =
    isDark ? Colors.white.withValues(alpha: 0.68) : const Color(0xFF475569);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─────────────────────────────────────
        // PRIMARY ACTION
        // ─────────────────────────────────────
        AppButton(
          label: 'Get Started',
          isFullWidth: true,
          icon: Icons.arrow_forward_rounded,
          onPressed: () => context.push(
            AppRoutes.roleSelection,
          ),
        ),

        const SizedBox(height: 20),

        // ─────────────────────────────────────
        // SECONDARY ACTION
        // ─────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(
                AppRoutes.login,
              ),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.22)
                        : const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 19,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Already have an account? Log In',
                      style: TextStyle(
                        fontSize: isSmallPhone ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ─────────────────────────────────────
        // TERTIARY ACTION
        // ─────────────────────────────────────
        TextButton(
          onPressed: () => context.push(
            AppRoutes.platformAdminLogin,
          ),
          style: TextButton.styleFrom(
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 17,
                color: mutedTextColor,
              ),
              const SizedBox(width: 7),
              Text(
                'Platform Administrator Login',
                style: TextStyle(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: mutedTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// BACKGROUND
// ============================================================================

class _WelcomeBackground extends StatelessWidget {
  final bool isDark;

  const _WelcomeBackground({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Clean, flat background colors instead of a gradient
      color: isDark ? const Color(0xFF0B1220) : const Color(0xFFF8FAFC),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _BackgroundGlow(
              size: 400,
              isDark: isDark,
            ),
          ),
          Positioned(
            bottom: -150,
            left: -120,
            child: _BackgroundGlow(
              size: 480,
              isDark: isDark,
            ),
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.35,
            right: MediaQuery.sizeOf(context).width * 0.20,
            child: _BackgroundGlow(
              size: 200,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;
  final bool isDark;

  const _BackgroundGlow({
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Extremely subtle ambient highlight instead of a harsh gradient glow
        color: AppColors.primary.withValues(
          alpha: isDark ? 0.03 : 0.04,
        ),
      ),
    );
  }
}

// ============================================================================
// CAMPUS NETWORK DECORATION
// ============================================================================

class _CampusNetworkPainter extends CustomPainter {
  const _CampusNetworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.045)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final nodes = [
      Offset(size.width * 0.05, size.height * 0.18),
      Offset(size.width * 0.16, size.height * 0.10),
      Offset(size.width * 0.90, size.height * 0.15),
      Offset(size.width * 0.96, size.height * 0.27),
      Offset(size.width * 0.04, size.height * 0.78),
      Offset(size.width * 0.15, size.height * 0.90),
      Offset(size.width * 0.88, size.height * 0.83),
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
        3.5,
        nodePaint,
      );

      canvas.drawCircle(
        node,
        8,
        Paint()..color = AppColors.primary.withValues(alpha: 0.03),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}