import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/service_provider.dart';

/// A wrapper widget that handles authentication state changes
/// and redirects users to the appropriate screen based on their auth status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.authService;

    // Listen to the authentication state changes
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while connection state is active
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;

          // If authenticated, show Home screen
          if (user != null) {
            return const HomeScreen();
          }

          // If not authenticated, show Login screen
          return const LoginScreen();
        }

        // Show loading indicator while waiting for auth state
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
