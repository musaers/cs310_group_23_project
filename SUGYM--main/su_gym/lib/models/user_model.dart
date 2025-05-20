import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final DateTime dateOfBirth;
  final DateTime createdAt;
  final MembershipModel membership;
  final FitnessModel fitness;
  final StatisticsModel statistics;
  final String? fcmToken;
  final DateTime? tokenUpdatedAt;
  final String? platform;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.dateOfBirth,
    required this.createdAt,
    required this.membership,
    required this.fitness,
    required this.statistics,
    this.fcmToken,
    this.tokenUpdatedAt,
    this.platform,
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      membership: MembershipModel.fromMap(data['membership'] ?? {}),
      fitness: FitnessModel.fromMap(data['fitness'] ?? {}),
      statistics: StatisticsModel.fromMap(data['statistics'] ?? {}),
      fcmToken: data['fcmToken'],
      tokenUpdatedAt:
          data['tokenUpdatedAt'] != null
              ? (data['tokenUpdatedAt'] as Timestamp).toDate()
              : null,
      platform: data['platform'],
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'createdAt': Timestamp.fromDate(createdAt),
      'membership': membership.toMap(),
      'fitness': fitness.toMap(),
      'statistics': statistics.toMap(),
      'fcmToken': fcmToken,
      'tokenUpdatedAt':
          tokenUpdatedAt != null ? Timestamp.fromDate(tokenUpdatedAt!) : null,
      'platform': platform,
    };
  }
}

class MembershipModel {
  final String plan;
  final String? planId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  MembershipModel({
    required this.plan,
    this.planId,
    this.startDate,
    this.endDate,
    required this.status,
  });

  // Convert Map to MembershipModel
  factory MembershipModel.fromMap(Map<String, dynamic> map) {
    return MembershipModel(
      plan: map['plan'] ?? 'None',
      planId: map['planId'],
      startDate:
          map['startDate'] != null
              ? (map['startDate'] as Timestamp).toDate()
              : null,
      endDate:
          map['endDate'] != null
              ? (map['endDate'] as Timestamp).toDate()
              : null,
      status: map['status'] ?? 'Inactive',
    );
  }

  // Convert MembershipModel to Map
  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'planId': planId,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status,
    };
  }
}

class FitnessModel {
  final int? currentWeight;
  final int? startingWeight;
  final int? targetWeight;
  final double progress;

  FitnessModel({
    this.currentWeight,
    this.startingWeight,
    this.targetWeight,
    required this.progress,
  });

  // Convert Map to FitnessModel
  factory FitnessModel.fromMap(Map<String, dynamic> map) {
    return FitnessModel(
      currentWeight: map['currentWeight'],
      startingWeight: map['startingWeight'],
      targetWeight: map['targetWeight'],
      progress: (map['progress'] ?? 0).toDouble(),
    );
  }

  // Convert FitnessModel to Map
  Map<String, dynamic> toMap() {
    return {
      'currentWeight': currentWeight,
      'startingWeight': startingWeight,
      'targetWeight': targetWeight,
      'progress': progress,
    };
  }
}

class StatisticsModel {
  final int weeklyVisits;
  final int monthlyVisits;
  final int totalVisits;
  final String mostAttendedClass;

  StatisticsModel({
    required this.weeklyVisits,
    required this.monthlyVisits,
    required this.totalVisits,
    required this.mostAttendedClass,
  });

  // Convert Map to StatisticsModel
  factory StatisticsModel.fromMap(Map<String, dynamic> map) {
    return StatisticsModel(
      weeklyVisits: map['weeklyVisits'] ?? 0,
      monthlyVisits: map['monthlyVisits'] ?? 0,
      totalVisits: map['totalVisits'] ?? 0,
      mostAttendedClass: map['mostAttendedClass'] ?? '',
    );
  }

  // Convert StatisticsModel to Map
  Map<String, dynamic> toMap() {
    return {
      'weeklyVisits': weeklyVisits,
      'monthlyVisits': monthlyVisits,
      'totalVisits': totalVisits,
      'mostAttendedClass': mostAttendedClass,
    };
  }
}
