import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _uid => _auth.currentUser?.uid;

  // User Collection Reference
  CollectionReference get users => _firestore.collection('users');

  // Classes Collection Reference
  CollectionReference get classes => _firestore.collection('classes');

  // Reservations Collection Reference
  CollectionReference get reservations => _firestore.collection('reservations');

  // Facilities Collection Reference
  CollectionReference get facilities => _firestore.collection('facilities');

  // Memberships Collection Reference
  CollectionReference get memberships => _firestore.collection('memberships');

  // Fetch current user profile data
  Future<DocumentSnapshot> getUserProfile() async {
    if (_uid == null) throw Exception('User not authenticated');
    return await users.doc(_uid).get();
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_uid == null) throw Exception('User not authenticated');
    return await users.doc(_uid).update(data);
  }

  // Get all gym classes
  Future<QuerySnapshot> getClasses() async {
    return await classes.orderBy('startTime').get();
  }

  // Get classes for a specific day
  Future<QuerySnapshot> getClassesByDay(String day) async {
    return await classes
        .where('day', isEqualTo: day)
        .orderBy('startTime')
        .get();
  }

  // Make a class reservation
  Future<void> createReservation(String classId, DateTime date) async {
    if (_uid == null) throw Exception('User not authenticated');

    // Get the class details
    DocumentSnapshot classDoc = await classes.doc(classId).get();

    // Create a reservation
    await reservations.add({
      'userId': _uid,
      'classId': classId,
      'className': classDoc['name'],
      'startTime': classDoc['startTime'],
      'endTime': classDoc['endTime'],
      'day': classDoc['day'],
      'date': date,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update class enrollment count
    await classes.doc(classId).update({'enrolled': FieldValue.increment(1)});

    // Update user statistics
    await updateUserStatistics();
  }

  // Get user reservations
  Future<QuerySnapshot> getUserReservations() async {
    if (_uid == null) throw Exception('User not authenticated');

    return await reservations
        .where('userId', isEqualTo: _uid)
        .orderBy('date')
        .get();
  }

  // Cancel a reservation
  Future<void> cancelReservation(String reservationId, String classId) async {
    // Update reservation status
    await reservations.doc(reservationId).update({'status': 'Cancelled'});

    // Decrement class enrollment
    await classes.doc(classId).update({'enrolled': FieldValue.increment(-1)});
  }

  // Update user statistics
  Future<void> updateUserStatistics() async {
    if (_uid == null) throw Exception('User not authenticated');

    // Count weekly visits
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));

    QuerySnapshot weeklyVisits =
        await reservations
            .where('userId', isEqualTo: _uid)
            .where('date', isGreaterThanOrEqualTo: weekStart)
            .where('date', isLessThanOrEqualTo: now)
            .where('status', isEqualTo: 'Approved')
            .get();

    // Count monthly visits
    DateTime monthStart = DateTime(now.year, now.month, 1);

    QuerySnapshot monthlyVisits =
        await reservations
            .where('userId', isEqualTo: _uid)
            .where('date', isGreaterThanOrEqualTo: monthStart)
            .where('date', isLessThanOrEqualTo: now)
            .where('status', isEqualTo: 'Approved')
            .get();

    // Find most attended class
    QuerySnapshot allVisits =
        await reservations
            .where('userId', isEqualTo: _uid)
            .where('status', isEqualTo: 'Approved')
            .get();

    Map<String, int> classCount = {};
    for (var doc in allVisits.docs) {
      String className = doc['className'];
      classCount[className] = (classCount[className] ?? 0) + 1;
    }

    String mostAttendedClass = '';
    int maxCount = 0;

    classCount.forEach((className, count) {
      if (count > maxCount) {
        maxCount = count;
        mostAttendedClass = className;
      }
    });

    // Update user statistics
    await users.doc(_uid).update({
      'statistics.weeklyVisits': weeklyVisits.docs.length,
      'statistics.monthlyVisits': monthlyVisits.docs.length,
      'statistics.totalVisits': allVisits.docs.length,
      'statistics.mostAttendedClass': mostAttendedClass,
    });
  }

  // Get facilities data
  Future<QuerySnapshot> getFacilities() async {
    return await facilities.get();
  }

  // Get membership plans
  Future<QuerySnapshot> getMembershipPlans() async {
    return await memberships.get();
  }

  // Update user membership
  Future<void> updateMembership(
    String planId,
    String planName,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_uid == null) throw Exception('User not authenticated');

    await users.doc(_uid).update({
      'membership.plan': planName,
      'membership.planId': planId,
      'membership.startDate': startDate,
      'membership.endDate': endDate,
      'membership.status': 'Active',
    });
  }

  // Submit feedback
  Future<void> submitFeedback({
    required double classRating,
    required double trainerRating,
    required double facilityRating,
    required double overallRating,
    required String feedback,
    String? selectedClass,
  }) async {
    if (_uid == null) throw Exception('User not authenticated');

    await _firestore.collection('feedback').add({
      'userId': _uid,
      'classRating': classRating,
      'trainerRating': trainerRating,
      'facilityRating': facilityRating,
      'overallRating': overallRating,
      'feedback': feedback,
      'selectedClass': selectedClass,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Record a gym visit
  Future<void> recordGymVisit() async {
    if (_uid == null) throw Exception('User not authenticated');

    await _firestore.collection('visits').add({
      'userId': _uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update user statistics
    await updateUserStatistics();
  }
}
