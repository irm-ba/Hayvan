import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String petId;
  final Timestamp date;
  final String description;
  final String treatment;
  final String veterinarianName;
  final String healthStatus;
  final String imageUrl;
  final String userId;

  HealthRecord({
    required this.petId,
    required this.date,
    required this.description,
    required this.treatment,
    required this.veterinarianName,
    required this.healthStatus,
    required this.imageUrl,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'date': date,
      'description': description,
      'treatment': treatment,
      'veterinarianName': veterinarianName,
      'healthStatus': healthStatus,
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      petId: map['petId'] as String,
      date: map['date'] as Timestamp,
      description: map['description'] as String,
      treatment: map['treatment'] as String,
      veterinarianName: map['veterinarianName'] as String,
      healthStatus: map['healthStatus'] as String,
      imageUrl: map['imageUrl'] as String,
      userId: map['userId'] as String,
    );
  }
}
