import 'package:cloud_firestore/cloud_firestore.dart';

class PetData {
  final String name;
  final String imageUrl;
  final String breed;
  final bool isGenderMale;
  final int age;
  final String healthStatus;
  final String healthCardImageUrl;
  final String animalType;
  final String location;
  final String description;
  final String petId;
  final String userId;

  PetData({
    required this.name,
    required this.imageUrl,
    required this.breed,
    required this.isGenderMale,
    required this.age,
    required this.healthStatus,
    required this.healthCardImageUrl,
    required this.animalType,
    required this.location,
    required this.description,
    required this.petId,
    required this.userId,
  });

  factory PetData.fromMap(Map<String, dynamic> map) {
    return PetData(
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      breed: map['breed'] ?? '',
      isGenderMale: map['isGenderMale'] ?? false,
      age: map['age'] ?? 0,
      healthStatus: map['healthStatus'] ?? '',
      healthCardImageUrl: map['healthCardImageUrl'] ?? '',
      animalType: map['animalType'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      petId: map['petId'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  factory PetData.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PetData.fromMap(data);
  }
}
