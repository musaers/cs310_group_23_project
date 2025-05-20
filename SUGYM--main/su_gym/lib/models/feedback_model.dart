import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final double classRating;
  final double trainerRating;
  final double facilityRating;
  final double overallRating;
  final String feedback;
  final String? selectedClass;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.classRating,
    required this.trainerRating,
    required this.facilityRating,
    required this.overallRating,
    required this.feedback,
    this.selectedClass,
    required this.createdAt,
  });

  // Convert Firestore document to FeedbackModel
  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return FeedbackModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      classRating: (data['classRating'] ?? 0).toDouble(),
      trainerRating: (data['trainerRating'] ?? 0).toDouble(),
      facilityRating: (data['facilityRating'] ?? 0).toDouble(),
      overallRating: (data['overallRating'] ?? 0).toDouble(),
      feedback: data['feedback'] ?? '',
      selectedClass: data['selectedClass'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert FeedbackModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'classRating': classRating,
      'trainerRating': trainerRating,
      'facilityRating': facilityRating,
      'overallRating': overallRating,
      'feedback': feedback,
      'selectedClass': selectedClass,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
