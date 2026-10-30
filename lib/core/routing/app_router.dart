import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/auth/verify_login_otp_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/admin_students_screen.dart';
import '../../features/admin/admin_courses_screen.dart';
import '../../features/teacher/teacher_dashboard_screen.dart';
import '../../features/teacher/qr_session_screen.dart';
import '../../features/teacher/noise_measurement_screen.dart';
import '../../features/student/student_dashboard_screen.dart';
import '../../features/student/qr_scanner_screen.dart';
import '../../features/student/student_location_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../storage/token_storage.dart';

class AppRouter {
  static final TokenStorage _tokenStorage = TokenStorage();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/verify-login-otp',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return VerifyLoginOtpScreen(
            challengeId: data['challengeId']?.toString() ?? '',
            email: data['email']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin-students',
        builder: (context, state) => const AdminStudentsScreen(),
      ),
      GoRoute(
        path: '/admin-courses',
        builder: (context, state) => const AdminCoursesScreen(),
      ),
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/teacher-qr',
        builder: (context, state) {
          final classSessionId = state.extra as String? ?? '';
          return QrSessionScreen(classSessionId: classSessionId);
        },
      ),
      GoRoute(
        path: '/teacher-noise',
        builder: (context, state) => const NoiseMeasurementScreen(),
      ),
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/student-qr-scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/student-location',
        builder: (context, state) => const StudentLocationScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    redirect: (context, state) async {
      final token = await _tokenStorage.getAccessToken();
      final isLoggingIn = state.uri.path == '/login' ||
          state.uri.path == '/register' ||
          state.uri.path == '/verify-email' ||
          state.uri.path == '/verify-login-otp';

      if (token == null || token.isEmpty) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        // Already logged in, check role or default to student dashboard
        final roles = await _tokenStorage.getRoles();
        if (roles.contains('Admin')) return '/admin-dashboard';
        if (roles.contains('Teacher')) return '/teacher-dashboard';
        return '/student-dashboard';
      }

      return null;
    },
  );
}
