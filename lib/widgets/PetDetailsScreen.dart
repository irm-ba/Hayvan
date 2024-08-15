import 'package:flutter/material.dart';
import 'package:pet_adoption/models/pet_data.dart';

class PetDetailsScreen extends StatelessWidget {
  final PetData pet;

  const PetDetailsScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(pet.imageUrl),
            SizedBox(height: 16),
            Text(
              pet.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              pet.breed,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              pet.isGenderMale ? 'Erkek' : 'Dişi',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '${pet.age} yaşında',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Sağlık Durumu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(pet.healthStatus),
            SizedBox(height: 16),
            if (pet.healthCardImageUrl.isNotEmpty) ...[
              Text(
                'Sağlık Kartı:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Image.network(pet.healthCardImageUrl),
              SizedBox(height: 16),
            ],
            Text(
              'Hayvan Türü:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(pet.animalType),
            SizedBox(height: 16),
            Text(
              'Lokasyon:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(pet.location),
            SizedBox(height: 16),
            Text(
              'Açıklama:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(pet.description),
          ],
        ),
      ),
    );
  }
}
