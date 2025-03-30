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
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/forgot-password': (context) => ForgotPasswordScreen(),
  
  // Home routes
  '/home': (context) => HomeScreen(),
  '/welcome': (context) => WelcomeScreen(),
  
  // Classes routes
  '/classes': (context) => ClassesScreen(),
  '/class-detail': (context) => ClassDetailScreen(),
  
  // Reservations routes
  '/reservations': (context) => ReservationsScreen(),
  '/qr-code': (context) => QRCodeScreen(),
  
  // Profile routes
  '/profile': (context) => ProfileScreen(),
  '/edit-profile': (context) => EditProfileScreen(),
  
  // Payment routes
  '/payment': (context) => PaymentScreen(),
  '/membership-plans': (context) => MembershipPlansScreen(),
  
  // Other routes
  '/leaderboard': (context) => LeaderboardScreen(),
  '/feedback': (context) => FeedbackScreen(),
  '/facilities': (context) => FacilitiesScreen(),
  '/notifications': (context) => NotificationsScreen(),
};
