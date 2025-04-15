import 'package:flutter/material.dart';

// Auth screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

// Home screens
import 'screens/home/home_screen.dart';
import 'screens/home/welcome_screen.dart';

// Classes screens
import 'screens/classes/classes_screen.dart';
import 'screens/classes/class_detail_screen.dart';

// Reservations screens
import 'screens/reservations/reservations_screen.dart';
import 'screens/reservations/qr_code_screen.dart';

// Profile screens
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';

// Payment screens
import 'screens/payment/payment_screen.dart';
import 'screens/payment/membership_plans_screen.dart';

// Other screens
import 'screens/social/leaderboard_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/facilities/facilities_screen.dart';
import 'screens/notifications/notifications_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Auth routes
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => const SignupScreen(),
  '/forgot-password': (context) => const ForgotPasswordScreen(),
  
  // Home routes
  '/home': (context) => const HomeScreen(),
  '/welcome': (context) => const WelcomeScreen(),
  
  // Classes routes
  '/classes': (context) => const ClassesScreen(),
  '/class-detail': (context) => const ClassDetailScreen(),
  
  // Reservations routes
  '/reservations': (context) => const ReservationsScreen(),
  '/qr-code': (context) => const QRCodeScreen(),
  
  // Profile routes
  '/profile': (context) => const ProfileScreen(),
  '/edit-profile': (context) => const EditProfileScreen(),
  
  // Payment routes
  '/payment': (context) => const PaymentScreen(),
  '/membership-plans': (context) => const MembershipPlansScreen(),
  
  // Other routes
  '/leaderboard': (context) => const LeaderboardScreen(),
  '/feedback': (context) => const FeedbackScreen(),
  '/facilities': (context) => const FacilitiesScreen(),
  '/notifications': (context) => const NotificationsScreen(),
};
