import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_service_app/core/services/providers.dart';
import 'package:local_service_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:local_service_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:local_service_app/features/auth/presentation/screens/login_screen.dart';
import 'package:local_service_app/features/auth/presentation/screens/register_screen.dart';
import 'package:local_service_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:local_service_app/features/home/presentation/screens/home_screen.dart';
import 'package:local_service_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:local_service_app/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:local_service_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:local_service_app/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:local_service_app/features/payments/presentation/screens/payment_screen.dart';
import 'package:local_service_app/features/maps/presentation/screens/map_screen.dart';
import 'package:local_service_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:local_service_app/features/providers/presentation/screens/provider_detail_screen.dart';
import 'package:local_service_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:local_service_app/core/widgets/root_scaffold.dart';

// ─── Route Names ──────────────────────────────────────────────────────────────

abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String booking = '/booking';
  static const String bookingDetail = '/booking/:id';
  static const String chatList = '/chats';
  static const String chatRoom = '/chats/:roomId';
  static const String payment = '/payment/:bookingId';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String providerDetail = '/provider/:id';
  static const String adminDashboard = '/admin';
}

// ─── Router Provider ──────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final hasToken = await tokenManager.hasValidToken();
      final onAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.otp ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.splash;

      if (!hasToken && !onAuth) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          String phone = '';
          if (state.extra is String) {
            phone = state.extra as String;
          } else if (state.extra is Map<String, dynamic>) {
            phone = (state.extra as Map<String, dynamic>)['phone'] as String? ?? '';
          }
          return OtpScreen(phone: phone);
        },
      ),
      // ─── Shell (Bottom Nav) ────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => RootScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.chatList,
            builder: (_, __) => const ChatListScreen(),
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (_, __) => const MapScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.booking,
        builder: (context, state) {
          final serviceId = state.extra as String? ?? '';
          return BookingScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BookingDetailScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return ChatRoomScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return PaymentScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: AppRoutes.providerDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProviderDetailScreen(providerId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (_, __) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
