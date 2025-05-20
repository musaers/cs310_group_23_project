import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String userId;
  final String classId;
  final String className;
  final String startTime;
  final String endTime;
  final String day;
  final DateTime date;
  final String status; // Approved, Pending, Cancelled
  final DateTime createdAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.classId,
    required this.className,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.date,
    required this.status,
    required this.createdAt,
  });

  // Convert Firestore document to ReservationModel
  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ReservationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      classId: data['classId'] ?? '',
      className: data['className'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      day: data['day'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert ReservationModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'classId': classId,
      'className': className,
      'startTime': startTime,
      'endTime': endTime,
      'day': day,
      'date': Timestamp.fromDate(date),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
