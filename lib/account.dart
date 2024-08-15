import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pet_adoption/models/pet_data.dart';
import 'EditProfile.dart';
import 'change_password_page.dart';
import 'Adoptiondetails.dart';
import 'dart:io';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _profileImage;
  Map<String, dynamic>? _userData;
  List<PetData> _userPets = [];
  List<DocumentSnapshot> _userApplications = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
        });

        QuerySnapshot petsSnapshot = await FirebaseFirestore.instance
            .collection('pet')
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        setState(() {
          _userPets = petsSnapshot.docs
              .map((doc) => PetData.fromSnapshot(doc))
              .toList();
        });

        List<String> petIds = _userPets.map((pet) => pet.petId).toList();
        if (petIds.isNotEmpty) {
          QuerySnapshot applicationsSnapshot = await FirebaseFirestore.instance
              .collection('adoption_applications')
              .where('petId', whereIn: petIds)
              .get();

          setState(() {
            _userApplications = applicationsSnapshot.docs;
          });
        } else {
          setState(() {
            _userApplications = [];
          });
        }
      } catch (e) {
        print('Error initializing data: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    // Burada, kullanıcının profil resmini seçmesini sağlayın
  }

  Future<void> _uploadImageToFirebaseAndSaveUrl() async {
    if (_profileImage == null) return;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images/${FirebaseAuth.instance.currentUser!.uid}.jpg');

    await storageRef.putFile(_profileImage!);

    final imageUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'profileImageUrl': imageUrl});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Hesap',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _userData == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  Expanded(child: _buildProfileDetails()),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(15.0), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50, // Reduced radius
              backgroundColor: Colors.white,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : NetworkImage(_userData!['profileImageUrl'] ??
                      'https://via.placeholder.com/150') as ImageProvider,
              child: _profileImage == null
                  ? Icon(Icons.camera_alt,
                      color: Colors.purple, size: 30) // Adjusted icon size
                  : null,
            ),
          ),
          SizedBox(height: 15), // Reduced space between image and text
          Text(
            _userData!['firstName'] ?? 'Kullanıcı Adı',
            style: TextStyle(
              fontSize: 22, // Slightly smaller text size
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 6),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 14, // Slightly smaller text size
              color: Colors.purple[300],
            ),
          ),
          SizedBox(height: 6),
          Text(
            _userData!['phoneNumber'] ?? 'Telefon numarası yok',
            style: TextStyle(
              fontSize: 14, // Slightly smaller text size
              color: Colors.purple[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _userData!['bio'] ?? 'Bio bulunmuyor',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildSectionTitle('Başvurularım'),
          _userApplications.isNotEmpty
              ? _buildApplicationsList()
              : Center(child: Text('Başvuru bulunmuyor')),
          SizedBox(height: 20),
          _buildSectionTitle('Hayvanlarım'),
          _userPets.isNotEmpty
              ? _buildPetsList()
              : Center(child: Text('Hayvanınız bulunmuyor')),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: _userApplications.length,
        itemBuilder: (context, index) {
          var application = _userApplications[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12.0),
              leading: Icon(Icons.pets, color: Colors.purple),
              title: Text(
                application['adoptionReason'] ?? 'Neden belirtilmemiş',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              subtitle: Text(
                application['petId'] ?? 'Hayvan ID belirtilmemiş',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ApplicationDetailPage(applicationId: application.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetsList() {
    return Container(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _userPets.length,
        separatorBuilder: (context, index) => SizedBox(width: 16),
        itemBuilder: (context, index) {
          final pet = _userPets[index];
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15.0)),
                      image: DecorationImage(
                        image: NetworkImage(
                            pet.imageUrl ?? 'https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name ?? 'Hayvan Adı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        pet.breed ?? 'Irk belirtilmemiş',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(15.0), // Adjusted padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
            icon: Icon(Icons.edit, color: Colors.white),
            label: Text('Profili Düzenle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
            icon: Icon(Icons.lock, color: Colors.white),
            label: Text('Şifreyi Değiştir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ApplicationDetailPage extends StatelessWidget {
  final String applicationId;

  const ApplicationDetailPage({Key? key, required this.applicationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Başvuru Detayları'),
      ),
      body: Center(
        child: Text('Başvuru ID: $applicationId'),
      ),
    );
  }
}
