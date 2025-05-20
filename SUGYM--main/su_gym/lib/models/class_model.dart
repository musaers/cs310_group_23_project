import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final String day;
  final String trainer;
  final int capacity;
  final int enrolled;
  final String description;
  final List<String> equipment;
  final String intensity;
  final String calories;
  final String location;
  final String? imageUrl;

  ClassModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.trainer,
    required this.capacity,
    required this.enrolled,
    required this.description,
    required this.equipment,
    required this.intensity,
    required this.calories,
    required this.location,
    this.imageUrl,
  });

  // Convert Firestore document to ClassModel
  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Ensure equipment is properly handled as a list
    List<String> equipmentList = [];
    if (data['equipment'] != null) {
      if (data['equipment'] is List) {
        equipmentList = List<String>.from(data['equipment']);
      } else if (data['equipment'] is String) {
        // Handle case where equipment is a single string
        equipmentList = [(data['equipment'] as String)];
      }
    }

    return ClassModel(
      id: doc.id,
      name: data['name'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      day: data['day'] ?? '',
      trainer: data['trainer'] ?? '',
      capacity: data['capacity'] ?? 0,
      enrolled: data['enrolled'] ?? 0,
      description: data['description'] ?? '',
      equipment: equipmentList,
      intensity: data['intensity'] ?? '',
      calories: data['calories'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  // Convert ClassModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'day': day,
      'trainer': trainer,
      'capacity': capacity,
      'enrolled': enrolled,
      'description': description,
      'equipment': equipment,
      'intensity': intensity,
      'calories': calories,
      'location': location,
      'imageUrl': imageUrl,
    };
  }

  // Create a copy of ClassModel with updated fields
  ClassModel copyWith({
    String? id,
    String? name,
    String? startTime,
    String? endTime,
    String? day,
    String? trainer,
    int? capacity,
    int? enrolled,
    String? description,
    List<String>? equipment,
    String? intensity,
    String? calories,
    String? location,
    String? imageUrl,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      day: day ?? this.day,
      trainer: trainer ?? this.trainer,
      capacity: capacity ?? this.capacity,
      enrolled: enrolled ?? this.enrolled,
      description: description ?? this.description,
      equipment: equipment ?? this.equipment,
      intensity: intensity ?? this.intensity,
      calories: calories ?? this.calories,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
