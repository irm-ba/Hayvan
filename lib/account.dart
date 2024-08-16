import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      body: Stack(
        children: [
          _buildBackground(),
          _userData == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCustomBackButton(),
                      SizedBox(height: 200),
                      _buildProfileHeader(),
                      _buildProfileDetails(),
                      _buildActionButtons(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 173, 121, 179),
            Color.fromARGB(255, 202, 121, 243)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: _HeaderPainter(),
        child: Container(height: 300),
      ),
    );
  }

  Widget _buildCustomBackButton() {
    return Positioned(
      top: 40, // Yükseklik ayarı
      left: 16, // Sol konum
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context); // Geri tuşuna basıldığında geri dön
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromARGB(255, 255, 252, 252),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : NetworkImage(_userData!['profileImageUrl'] ??
                            'https://via.placeholder.com/150') as ImageProvider,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            _userData!['firstName'] ?? 'Kullanıcı Adı',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 4),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _userData!['phoneNumber'] ?? 'Telefon numarası yok',
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Başvurularım'),
          _userApplications.isNotEmpty
              ? _buildApplicationsList()
              : Center(child: Text('Başvuru bulunmuyor')),
          SizedBox(height: 20),
          _buildSectionTitle('Hayvanlarım'),
          _userPets.isNotEmpty
              ? _buildPetsList()
              : Center(child: Text('Hayvanınız bulunmuyor')),
          SizedBox(height: 40),
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
          fontSize: 20,
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
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12.0),
              leading: Icon(Icons.pets, color: Colors.purple),
              title: Text(
                application['adoptionReason'] ?? 'Neden belirtilmemiş',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
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
        separatorBuilder: (context, index) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          var pet = _userPets[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  child: Container(
                    width: 160,
                    height: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          pet.imageUrl ?? 'https://via.placeholder.com/150',
                        ),
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
      padding: const EdgeInsets.all(16.0),
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
            label: Text(
              'Profili Düzenle',
              style:
                  TextStyle(color: Colors.white), // Buton yazısının rengi beyaz
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple, // Buton arka plan rengi mor
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
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
            label: Text(
              'Şifreyi Değiştir',
              style:
                  TextStyle(color: Colors.white), // Buton yazısının rengi beyaz
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple, // Buton arka plan rengi mor
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    var path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.5, size.height, size.width, size.height * 0.6)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ApplicationDetailPage extends StatelessWidget {
  final String applicationId;

  const ApplicationDetailPage({Key? key, required this.applicationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Başvuru ID: $applicationId'),
      ),
    );
  }
}
