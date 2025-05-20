import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'auth_service.dart';
import 'firestore_service.dart';
import 'storage_service.dart';
import 'analytics_service.dart';
import 'notification_service.dart';

/// A provider class that manages all Firebase services
class ServiceProvider extends InheritedWidget {
  // Create service instances
  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();
  final StorageService storageService = StorageService();
  final AnalyticsService analyticsService = AnalyticsService();

  late final NotificationService notificationService;

  ServiceProvider({Key? key, required Widget child})
    : super(key: key, child: child) {
    // Initialize notification service with FlutterLocalNotificationsPlugin
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    notificationService = NotificationService(flutterLocalNotificationsPlugin);
  }

  // Get the instance from context
  static ServiceProvider of(BuildContext context) {
    final ServiceProvider? result =
        context.dependOnInheritedWidgetOfExactType<ServiceProvider>();
    assert(result != null, 'No ServiceProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ServiceProvider oldWidget) => false;
}

/// Extension methods for easier service access from BuildContext
extension ServiceProviderExtension on BuildContext {
  AuthService get authService => ServiceProvider.of(this).authService;
  FirestoreService get firestoreService =>
      ServiceProvider.of(this).firestoreService;
  StorageService get storageService => ServiceProvider.of(this).storageService;
  AnalyticsService get analyticsService =>
      ServiceProvider.of(this).analyticsService;
  NotificationService get notificationService =>
      ServiceProvider.of(this).notificationService;
}
