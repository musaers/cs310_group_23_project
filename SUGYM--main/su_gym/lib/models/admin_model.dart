// lib/models/admin_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final String
      role; // 'super_admin', 'admin', 'moderator' gibi roller tanımlanabilir
  final List<String>
      permissions; // 'manage_users', 'manage_classes', vs gibi izinler

  AdminModel({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.role,
    required this.permissions,
  });

  // Firestore'dan Admin modeli oluştur
  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      role: data['role'] ?? 'admin',
      permissions: List<String>.from(data['permissions'] ?? []),
    );
  }

  // Admin modelini Firestore için Map'e dönüştür
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'createdAt': Timestamp.fromDate(createdAt),
      'role': role,
      'permissions': permissions,
    };
  }
}

