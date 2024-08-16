import 'dart:io'; // Add this import
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soru Ekle'),
        backgroundColor: Color(0xFFC478D1), // Color updated
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Sorunuzu giriniz',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _selectedImages.map((image) {
                return Stack(
                  children: [
                    Image.file(File(image.path), width: 100, height: 100),
                    Positioned(
                      right: 0,
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
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text("Resim Ekle"),
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC478D1)), // Color updated
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitQuestion,
              child: Text('Gönder'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC478D1)), // Color updated
            ),
          ],
        ),
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
      // Error: Too many images selected
    }
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.isEmpty || _selectedImages.isEmpty) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      var userInfo = userData.data() as Map<String, dynamic>?;

      if (userInfo != null) {
        List<String> imageUrls = await _uploadImages();

        await FirebaseFirestore.instance.collection('forumQuestions').add({
          'userId': user.uid,
          'userName':
              "${userInfo['firstName'] ?? 'İsim Yok'} ${userInfo['lastName'] ?? 'Soyisim Yok'}",
          'question': _questionController.text,
          'timestamp': Timestamp.now(),
          'imageUrls': imageUrls,
        });

        Navigator.pop(context);
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var image in _selectedImages) {
      final ref = FirebaseStorage.instance.ref().child(
          'questions/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      await ref.putFile(File(image.path));
      String url = await ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }
}
