import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'app_routes.dart';
import '../features/splash/views/splash_screen.dart';
import '../features/welcome/views/welcome_screen.dart';
import '../features/auth/views/auth_screen.dart';
import '../features/auth/views/role_selection_screen.dart';
import '../features/auth/views/student_onboarding_screen.dart';
import '../features/auth/views/faculty_onboarding_screen.dart';
import '../features/college_registration/views/college_registration_screen.dart';
import '../features/auth/views/status_screens.dart';
import '../features/navigation/views/main_navigation_shell.dart';
import '../features/home/views/home_screen.dart';
import '../features/explore/views/explore_screen.dart';
import '../features/academics/views/academics_screen.dart';
import '../features/events/views/events_screen.dart';
import '../features/chats/views/chats_screen.dart';
import '../features/notifications/views/notifications_screen.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/college_admin/views/college_admin_dashboard_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  redirect: (context, state) async {
    final location = state.matchedLocation;
    final currentUser = fb.FirebaseAuth.instance.currentUser;

    // 2. Guard College Administrator Dashboard against unauthenticated users
    if (location.startsWith('/college-admin/dashboard')) {
      if (currentUser == null) {
        return AppRoutes.welcome;
      }
    }

    // 3. Guard general protected student/faculty shell routes if logged out
    if (location.startsWith('/app/') && currentUser == null) {
      return AppRoutes.welcome;
    }

    return null;
  },
  routes: [
    // Splash
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Public Welcome & Login
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    // Role Onboarding & College Registration Routes
    GoRoute(
      path: AppRoutes.studentOnboarding,
      builder: (context, state) => const StudentOnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.facultyOnboarding,
      builder: (context, state) => const FacultyOnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.collegeAdminOnboarding,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CollegeRegistrationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.collegeRegister,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CollegeRegistrationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // Status Routes
    GoRoute(
      path: AppRoutes.facultyVerificationPending,
      builder: (context, state) => const FacultyPendingScreen(),
    ),
    GoRoute(
      path: AppRoutes.collegeRegistrationPending,
      builder: (context, state) => const CollegePendingScreen(),
    ),
    GoRoute(
      path: AppRoutes.collegeRegistrationRejected,
      builder: (context, state) => const CollegeRejectedScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountSuspended,
      builder: (context, state) => const AccountSuspendedScreen(),
    ),

    // Student & Faculty Bottom Navigation Shell Route
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.academics,
              builder: (context, state) => const AcademicsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.events,
              builder: (context, state) => const EventsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chats,
              builder: (context, state) => const ChatsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Universal Shell Header Pushed Routes
    GoRoute(
      path: AppRoutes.notifications,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),

    // College Administrator Dashboard
    GoRoute(
      path: AppRoutes.collegeAdminDashboard,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CollegeAdminDashboardScreen(),
    ),
  ],
);