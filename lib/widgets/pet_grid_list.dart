import 'package:flutter/material.dart';
import 'package:pet_adoption/models/pet_data.dart';
import 'package:pet_adoption/screens/pet_details.dart';
import 'package:pet_adoption/widgets/CustomBottomNavigationBar.dart';

class PetGridList extends StatelessWidget {
  final List<PetData> pets;

  const PetGridList({Key? key, required this.pets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Son Eklenen Hayvanlar'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 0.75,
        ),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          PetData pet =
              pets[index]; // pets listesinden ilgili pet verisini alın

          return GestureDetector(
            onTap: () {
              // Pet ayrıntılarına gitmek için Navigator kullanın
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailsScreen(pet: pet),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 147, 97, 150),
                gradient: const LinearGradient(
                  colors: [
                    Colors.black12,
                    Colors.black54,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  image: NetworkImage(pet.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    pet.breed,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        pet.isGenderMale ? Icons.male : Icons.female,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pet.isGenderMale ? 'Erkek' : 'Dişi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pet.age} yaşında',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
