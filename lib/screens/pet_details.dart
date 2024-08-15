import 'package:flutter/material.dart';
import 'package:pet_adoption/models/pet_data.dart';
import '../AdoptionApplicationForm.dart'; // Import the application form
import 'package:firebase_auth/firebase_auth.dart';

class PetDetailsScreen extends StatelessWidget {
  final PetData pet;

  const PetDetailsScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final petOwnerId =
        FirebaseAuth.instance.currentUser?.uid; // Kullanıcı ID'sini alın

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pet.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImageSection(context),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoCard(
                    title: 'Yaş',
                    content: '${pet.age} yaşında',
                    icon: Icons.cake,
                    iconColor: Colors.purple[300],
                  ),
                  buildInfoCard(
                    title: 'Sağlık Durumu',
                    content: pet.healthStatus,
                    icon: Icons.local_hospital,
                    iconColor: Colors.red[300],
                  ),
                  buildInfoCard(
                    title: 'Hayvan Türü',
                    content: pet.animalType,
                    icon: Icons.pets,
                    iconColor: Colors.orange[300],
                  ),
                  buildInfoCard(
                    title: 'Lokasyon',
                    content: pet.location,
                    icon: Icons.location_on,
                    iconColor: Colors.blue[300],
                  ),
                  buildInfoCard(
                    title: 'Açıklama',
                    content: pet.description,
                    icon: Icons.description,
                    iconColor: Colors.green[300],
                  ),
                  if (pet.healthCardImageUrl.isNotEmpty)
                    buildHealthCard(context)
                  else
                    buildNoHealthCardMessage(),
                  SizedBox(height: 24),
                  Center(
                    child: buildAdoptionButton(
                        context, petOwnerId), // Parametreyi geçin
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 500,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(pet.imageUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Text(
            pet.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: iconColor!.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          subtitle: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHealthCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'Sağlık Kartı:',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.purple[800],
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImage(
                  imageUrl: pet.healthCardImageUrl,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              pet.healthCardImageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNoHealthCardMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        'Sağlık kartı bulunmuyor.',
        style: TextStyle(
          fontSize: 18,
          color: Colors.purple[700],
        ),
      ),
    );
  }

  Widget buildAdoptionButton(BuildContext context, String? petOwnerId) {
    return ElevatedButton.icon(
      onPressed: () {
        if (petOwnerId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AdoptionApplicationForm(petOwnerId: petOwnerId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kullanıcı oturum açmamış.')),
          );
        }
      },
      icon: Icon(Icons.favorite, color: Colors.white),
      label: Text('Sahiplen'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 120),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:
            Text('Sağlık Kartı', style: TextStyle(color: Colors.purple[800])),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
