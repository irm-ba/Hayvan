import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_adoption/models/pet_data.dart';
import 'EditProfile.dart';
import 'Change_Password_Page.dart';
import 'dart:io';
import 'adminaplication.dart'; // Import the AdminApplication page

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  File? _profileImage;
  Map<String, dynamic>? _userData;
  List<PetData> _userPets = [];
  List<DocumentSnapshot> _userApplications = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _tabController = TabController(length: 2, vsync: this);
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadImageToFirebaseAndSaveUrl();
    }
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
        title: Text('Profil'),
      ),
      body: _userData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(child: _buildTabBarView()),
                _buildActionButtons(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Arka plandaki resim
        Positioned.fill(
          child: Image.asset(
            'assets/proarka.jpg', // Resmi projeye dahil ettiğinizde bu yolu kullanın
            fit: BoxFit.cover,
          ),
        ),
        // Üzerindeki içerikler
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          color: Colors.white.withOpacity(
              0.5), // Arka planı hafif şeffaf yaparak resmi göstermek için
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : NetworkImage(_userData?['profileImageUrl'] ??
                            'https://via.placeholder.com/150') as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                _userData?['firstName'] ?? 'Kullanıcı Adı',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: 'Hayvanlarım'),
        Tab(text: 'Başvuranlar'),
      ],
      indicatorColor: Color.fromARGB(255, 147, 58, 142),
      labelColor: Color.fromARGB(255, 147, 58, 142),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPetsList(),
        _buildApplicationsList(),
      ],
    );
  }

  Widget _buildPetsList() {
    return _userPets.isNotEmpty
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Kartlar için oran
            ),
            padding: EdgeInsets.all(16),
            itemCount: _userPets.length,
            itemBuilder: (context, index) {
              var pet = _userPets[index];
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        pet.imageUrl,
                        height: MediaQuery.of(context).size.width / 2 -
                            32, // Kare yapacak şekilde ayarla
                        width: MediaQuery.of(context).size.width / 2 -
                            32, // Kare yapacak şekilde ayarla
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        pet.name ?? 'Hayvan Adı',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : Center(child: Text('Hayvanınız bulunmuyor'));
  }

  Widget _buildApplicationsList() {
    return _userApplications.isNotEmpty
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Kartlar için oran
            ),
            padding: EdgeInsets.all(16),
            itemCount: _userApplications.length,
            itemBuilder: (context, index) {
              var application = _userApplications[index];
              String userId = application['userId'];
              String petId = application['petId'];

              return FutureBuilder<List<DocumentSnapshot>>(
                future: Future.wait([
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  FirebaseFirestore.instance.collection('pet').doc(petId).get(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.length != 2) {
                    return Center(child: Text('Veri yüklenemedi.'));
                  }

                  DocumentSnapshot userDoc = snapshot.data![0];
                  DocumentSnapshot petDoc = snapshot.data![1];

                  final userData = userDoc.data() as Map<String, dynamic>?;
                  final petData = petDoc.data() as Map<String, dynamic>?;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminApplication(
                            applicationId: application.id,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              petData?['imageUrl'] ??
                                  'https://via.placeholder.com/150',
                              height: MediaQuery.of(context).size.width / 2 -
                                  32, // Kare yapacak şekilde ayarla
                              width: MediaQuery.of(context).size.width / 2 -
                                  32, // Kare yapacak şekilde ayarla
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              petData?['name'] ?? 'Hayvan Adı',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              userData?['firstName'] ?? 'Başvuran Adı',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )
        : Center(child: Text('Başvurunuz bulunmuyor'));
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
            child: Text('Profil Düzenle'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 255, 255, 255),
              backgroundColor: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
            child: Text('Şifre Değiştir'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 255, 255, 255),
              backgroundColor: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
        ],
      ),
    );
  }
}
