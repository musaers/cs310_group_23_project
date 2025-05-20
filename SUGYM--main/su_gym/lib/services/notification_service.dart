import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;

  // Notification channel for Android
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  NotificationService(this._localNotifications) {
    _initializeNotifications();
  }

  // Get current user ID
  String? get _uid => _auth.currentUser?.uid;

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print(
      'User notification permission status: ${settings.authorizationStatus}',
    );

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get and save FCM token
    String? token = await _messaging.getToken();
    if (token != null && _uid != null) {
      await _saveToken(token);
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen((token) async {
      if (_uid != null) {
        await _saveToken(token);
      }
    });
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Show notification if it has a notification payload and is on Android
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android.smallIcon,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'],
      );
    }

    // Store notification in Firestore if user is authenticated
    if (_uid != null) {
      await _storeNotification(message);
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');

    // Handle navigation based on payload
    final String? route = message.data['route'];
    if (route != null && route.isNotEmpty) {
      // Navigate to the specific route
      // This would be handled by your app's navigation system
      print('Should navigate to route: $route');
    }
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation based on payload
    final String? route = response.payload;
    if (route != null && route.isNotEmpty) {
      // Navigate to the specific route
      // This would be handled by your app's navigation system
      print('Should navigate to route: $route');
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveToken(String token) async {
    if (_uid == null) return;

    await _firestore.collection('users').doc(_uid).update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
      'platform': _getPlatform(),
    });
  }

  // Get platform name
  String _getPlatform() {
    if (identical(0, 0.0)) {
      return 'iOS'; // iOS
    } else {
      return 'Android'; // Android/other
    }

    // Note: In a real app, use:
    // import 'dart:io' show Platform;
    // return Platform.isIOS ? 'iOS' : 'Android';
  }

  // Store notification in Firestore
  Future<void> _storeNotification(RemoteMessage message) async {
    if (_uid == null) return;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .add({
          'title': message.notification?.title,
          'body': message.notification?.body,
          'data': message.data,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
  }

  // Get all notifications for current user
  Future<QuerySnapshot> getNotifications() async {
    if (_uid == null) throw Exception('User not authenticated');

    return await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (_uid == null) throw Exception('User not authenticated');

    QuerySnapshot unreadNotifications =
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .get();

    WriteBatch batch = _firestore.batch();

    for (var doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // Set up notification topics for user
  Future<void> setupUserTopics(String membershipPlan) async {
    // Unsubscribe from all membership plan topics first
    await unsubscribeFromTopic('membership_free');
    await unsubscribeFromTopic('membership_premium');
    await unsubscribeFromTopic('membership_student');

    // Subscribe to general topic
    await subscribeToTopic('all_users');

    // Subscribe to membership-specific topic
    String membershipTopic = 'membership_${membershipPlan.toLowerCase()}';
    await subscribeToTopic(membershipTopic);
  }
}
