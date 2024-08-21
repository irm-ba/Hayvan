import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionPage extends StatefulWidget {
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  String? _profileImageUrl;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        var userInfo = userData.data() as Map<String, dynamic>?;

        setState(() {
          _profileImageUrl = userInfo?['profileImageUrl'];
          _userName =
              "${userInfo?['firstName'] ?? 'İsim Yok'} ${userInfo?['lastName'] ?? 'Soyisim Yok'}";
        });
      } catch (e) {
        print("Error loading user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Kullanıcı bilgileri yüklenirken bir hata oluştu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soru Ekle'),
      ),
      body: Stack(
        children: [
          // Background shapes
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 147, 58, 142),
                    Color(0xFFC478D1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFC478D1),
                    Color.fromARGB(255, 147, 58, 142)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_profileImageUrl != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(_profileImageUrl!),
                        backgroundColor: Colors.grey[200],
                      ),
                      SizedBox(width: 10),
                      Text(
                        _userName ?? 'İsim Yok',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Sorunuzu giriniz',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 147, 58, 142)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedImages.map((image) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(image.path),
                              width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImages.remove(image);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library, color: Colors.white),
                  label: Text("Resim Ekle"),
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 147, 58, 142),
                    foregroundColor: Color.fromARGB(255, 255, 254, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitQuestion,
                  child: Text('Gönder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 147, 58, 142),
                    foregroundColor: Color.fromARGB(255, 255, 254, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images != null && images.length <= 3) {
      setState(() {
        _selectedImages = images;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('En fazla 3 resim seçebilirsiniz')),
      );
    }
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.isEmpty || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Soru ve resimler gereklidir')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        List<String> imageUrls = await _uploadImages();

        await FirebaseFirestore.instance.collection('forumMessages').add({
          'userId': user.uid,
          'userName': _userName ?? 'İsim Yok',
          'profileImageUrl': _profileImageUrl ?? '',
          'question': _questionController.text,
          'timestamp': Timestamp.now(),
          'imageUrls': imageUrls,
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Soru başarıyla gönderildi!')),
        );
      } catch (e) {
        print("Error submitting question: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
        );
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var image in _selectedImages) {
      final ref = FirebaseStorage.instance.ref().child(
          'questions/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      try {
        await ref.putFile(File(image.path));
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
        print("Error uploading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim yüklenirken bir hata oluştu')),
        );
      }
    }
    return imageUrls;
  }
}
