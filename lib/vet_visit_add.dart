import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VetVisitAdd extends StatefulWidget {
  const VetVisitAdd({Key? key}) : super(key: key);

  @override
  _VetVisitAddState createState() => _VetVisitAddState();
}

class _VetVisitAddState extends State<VetVisitAdd> {
  final _descriptionController = TextEditingController();
  final _visitDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedAnimalId;
  List<String> _animalIds = [];
  List<String> _animalNames = [];
  List<String> _animalImageUrls = [];
  File? _selectedImage;
  String? _selectedAnimalName;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
  }

  Future<void> _fetchAnimals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final petsSnapshot = await FirebaseFirestore.instance
            .collection('pet')
            .where('userId', isEqualTo: user.uid)
            .get();

        setState(() {
          _animalIds = petsSnapshot.docs.map((doc) => doc.id).toList();
          _animalNames = petsSnapshot.docs
              .map((doc) => doc.data()['name'] as String)
              .toList();
          _animalImageUrls = petsSnapshot.docs
              .map((doc) => doc.data()['imageUrl'] as String)
              .toList();
        });
      } catch (e) {
        print('Error fetching animals: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veteriner Ziyareti Ekle'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veteriner ziyareti bilgilerini doldurun.',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 147, 58, 142),
                              ),
                        ),
                        SizedBox(height: 20),
                        _buildDropdownField(
                          label: 'Hayvan Seç',
                          value: _selectedAnimalId,
                          items: _animalIds,
                          itemNames: _animalNames,
                          itemImageUrls: _animalImageUrls,
                          onChanged: (value) {
                            setState(() {
                              if (value != 'custom') {
                                _selectedAnimalId = value;
                                _selectedAnimalName =
                                    _animalNames[_animalIds.indexOf(value!)];
                                _selectedImage =
                                    null; // Clear selected image if animal is selected
                              } else {
                                _selectedAnimalId = null;
                                _selectedAnimalName = null;
                              }
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Açıklama',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Açıklama girin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: _selectDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _visitDateController,
                              label: 'Ziyaret Tarihi',
                              hint: 'YYYY-MM-DD',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ziyaret tarihi girin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildImagePicker(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _addVetVisit,
                    child: const Text('Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 147, 58, 142),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required List<String> itemNames,
    required List<String> itemImageUrls,
    required void Function(String?) onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: List.generate(items.length, (index) {
          return DropdownMenuItem<String>(
            value: items[index],
            child: Row(
              children: [
                itemImageUrls[index].isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          itemImageUrls[index],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : SizedBox(width: 40, height: 40),
                Text(itemNames[index]),
              ],
            ),
          );
        })
          ..add(
            DropdownMenuItem<String>(
              value: 'custom',
              child: Row(
                children: [
                  Icon(Icons.add_a_photo, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text('Diğer Resim Ekle'),
                ],
              ),
            ),
          ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Hayvan seçin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: _selectedImage != null
            ? Image.file(
                _selectedImage!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              )
            : Icon(Icons.add_a_photo, color: Colors.grey[600]),
        title: Text(
          _selectedImage != null
              ? 'Resim Seçildi ($_selectedAnimalName)'
              : 'Resim Seç',
        ),
        onTap: _pickImage,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _visitDateController.text =
            '${picked.toLocal().toIso8601String().split('T').first}';
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final imageRef = storageRef.child('vetVisitImages/$fileName');
      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addVetVisit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String animalImageUrl;
        if (_selectedAnimalId != null &&
            _animalIds.contains(_selectedAnimalId)) {
          animalImageUrl =
              _animalImageUrls[_animalIds.indexOf(_selectedAnimalId!)];
        } else if (_selectedImage != null) {
          final uploadedImageUrl = await _uploadImage(_selectedImage!);
          if (uploadedImageUrl != null) {
            animalImageUrl = uploadedImageUrl;
          } else {
            animalImageUrl = '';
          }
        } else {
          animalImageUrl = '';
        }

        try {
          await FirebaseFirestore.instance.collection('vet_visits').add({
            'userId': user.uid,
            'animalId': _selectedAnimalId,
            'description': _descriptionController.text,
            'visitDate': _visitDateController.text,
            'animalImageUrl': animalImageUrl,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Veteriner ziyareti eklendi!')),
          );
          Navigator.pop(context);
        } catch (e) {
          print('Error adding vet visit: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Veteriner ziyareti eklenirken bir hata oluştu.')),
          );
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }
}
