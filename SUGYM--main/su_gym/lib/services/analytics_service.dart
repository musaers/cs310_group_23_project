import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log login event
  Future<void> logLogin(String loginMethod) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  // Log sign up event
  Future<void> logSignUp(String signUpMethod) async {
    await _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  // Log reservation created event
  Future<void> logReservationCreated(String className, String dateTime) async {
    await _analytics.logEvent(
      name: 'reservation_created',
      parameters: {'class_name': className, 'date_time': dateTime},
    );
  }

  // Log reservation canceled event
  Future<void> logReservationCanceled(String className, String dateTime) async {
    await _analytics.logEvent(
      name: 'reservation_canceled',
      parameters: {'class_name': className, 'date_time': dateTime},
    );
  }

  // Log class viewed event
  Future<void> logClassViewed(String className) async {
    await _analytics.logEvent(
      name: 'class_viewed',
      parameters: {'class_name': className},
    );
  }

  // Log membership purchased event
  Future<void> logMembershipPurchased(
    String planName,
    double price,
    int duration,
  ) async {
    await _analytics.logEvent(
      name: 'membership_purchased',
      parameters: {
        'plan_name': planName,
        'price': price,
        'duration_months': duration,
      },
    );
  }

  // Log feedback submitted event
  Future<void> logFeedbackSubmitted(double rating) async {
    await _analytics.logEvent(
      name: 'feedback_submitted',
      parameters: {'rating': rating},
    );
  }

  // Log profile updated event
  Future<void> logProfileUpdated() async {
    await _analytics.logEvent(name: 'profile_updated');
  }

  // Log screen view event
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Set user properties
  Future<void> setUserProperties({
    required String userId,
    String? membershipPlan,
  }) async {
    await _analytics.setUserId(id: userId);

    if (membershipPlan != null) {
      await _analytics.setUserProperty(
        name: 'membership_plan',
        value: membershipPlan,
      );
    }
  }
}
