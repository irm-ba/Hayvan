class LostAnimalData {
  final String name;
  final String breed;
  final bool isGenderMale;
  final int age;
  final List<String> imageUrls;
  final String description;
  final String location;
  final String userId;
  final String lostAnimalId;
  final String animalType;

  LostAnimalData({
    required this.name,
    required this.breed,
    required this.isGenderMale,
    required this.age,
    required this.imageUrls,
    required this.description,
    required this.location,
    required this.userId,
    required this.lostAnimalId,
    required this.animalType,
  });

  // Firestore'a veri eklemek için kullanılabilir bir `toMap` fonksiyonu
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'isGenderMale': isGenderMale,
      'age': age,
      'imageUrls': imageUrls,
      'description': description,
      'location': location,
      'userId': userId,
      'lostAnimalId': lostAnimalId,
      'animalType': animalType,
    };
  }

  // Firestore'dan veri almak için kullanılabilir bir `fromMap` fonksiyonu
  factory LostAnimalData.fromMap(Map<String, dynamic> map) {
    return LostAnimalData(
      name: map['name'],
      breed: map['breed'],
      isGenderMale: map['isGenderMale'],
      age: map['age'],
      imageUrls: List<String>.from(map['imageUrls']),
      description: map['description'],
      location: map['location'],
      userId: map['userId'],
      lostAnimalId: map['lostAnimalId'],
      animalType: map['animalType'],
    );
  }
}
