import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_logo.dart';
import '../../../routing/app_routes.dart';
import '../../../services/startup_resolver_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final StartupResolverService _startupResolver = StartupResolverService();

  late AnimationController _heroController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: const ElasticOutCurve(0.9)),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );

    _heroController.forward();
    _initializeAppAndRoute();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeAppAndRoute() async {
    setState(() => _hasError = false);
    // Enforce smooth branded splash duration
    await Future.delayed(const Duration(milliseconds: 2000));
    try {
      final destination = await _startupResolver.resolveStartupDestination();
      if (!mounted) return;

      if (destination == StartupDestination.error) {
        setState(() => _hasError = true);
        return;
      }

      final route = StartupResolverService.routeForDestination(destination);
      context.go(route);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.35),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.03 + (_pulseController.value * 0.03)),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.15),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.05 + (_pulseController.value * 0.06)),
                          ),
                        ),
                      );
                    },
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: const AppLogo(iconSize: 72, fontSize: 32, showTagline: false),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalXl,
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Everything your campus, connected.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                      AppSpacing.verticalSm,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'The unified institutional platform for academics, events, and community.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              letterSpacing: 0.1,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    if (_hasError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton.icon(
                          onPressed: _initializeAppAndRoute,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry Connection'),
                        ),
                      )
                    else
                      SizedBox(
                        width: 48,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                              minHeight: 3.0,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                        ),
                      ),
                    AppSpacing.verticalLg,
                    Text(
                      'v${AppConstants.appVersion}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.white38 : Colors.black38),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}