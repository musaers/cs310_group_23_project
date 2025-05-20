import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool read;

  NotificationModel({
    required this.id,
    this.title,
    this.body,
    required this.data,
    required this.timestamp,
    required this.read,
  });

  // Convert Firestore document to NotificationModel
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      title: docData['title'],
      body: docData['body'],
      data: docData['data'] ?? {},
      timestamp: (docData['timestamp'] as Timestamp).toDate(),
      read: docData['read'] ?? false,
    );
  }

  // Convert NotificationModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
    };
  }
}
