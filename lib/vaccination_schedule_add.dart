import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class VaccinationScheduleAdd extends StatefulWidget {
  const VaccinationScheduleAdd({Key? key}) : super(key: key);

  @override
  _VaccinationScheduleAddState createState() => _VaccinationScheduleAddState();
}

class _VaccinationScheduleAddState extends State<VaccinationScheduleAdd> {
  DateTime? start;
  DateTime? end;
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedAnimalId;
  List<String> _animalIds = [];
  List<String> _animalNames = [];
  List<String> _animalImageUrls = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _newAnimalImage; // Yeni eklenen hayvan resmi için

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

  Future<String> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child('vaccination_images/${DateTime.now().toIso8601String()}');
      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newAnimalImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveVaccinationSchedule() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String? imageUrl;
          if (_newAnimalImage != null) {
            imageUrl = await _uploadImage(_newAnimalImage!);
          }

          await FirebaseFirestore.instance
              .collection('vaccinationSchedules')
              .add({
            'description': _descriptionController.text,
            'start': start,
            'end': end,
            'animalId': _selectedAnimalId,
            'userId': user.uid,
            'animalImageUrl': imageUrl, // Resim URL'sini ekleyin
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aşı takvimi eklendi!')),
          );
          Navigator.pop(context);
        } catch (e) {
          print('Error adding vaccination schedule: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aşı takvimi eklenirken bir hata oluştu.')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aşı Takvimi Ekle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aşı takvimi bilgilerini doldurun.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 147, 58, 142),
                    ),
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                label: 'Hayvan Seç (Opsiyonel)',
                value: _selectedAnimalId,
                items: _animalIds,
                itemNames: _animalNames,
                itemImageUrls: _animalImageUrls,
                onChanged: (value) {
                  setState(() {
                    _selectedAnimalId = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Yeni Hayvan Resmi Seç"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 147, 58, 142),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (_newAnimalImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    _newAnimalImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                start != null && end != null
                    ? 'Başlangıç: ${_formatDate(start!)} \nBitiş: ${_formatDate(end!)}'
                    : 'Tarihleri seçin',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (result != null) {
                    setState(() {
                      start = result.start;
                      end = result.end;
                    });
                  }
                },
                child: const Text("Tarihleri Seç"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 147, 58, 142),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveVaccinationSchedule,
                      child: const Text("Kaydet"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 147, 58, 142),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
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
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(itemImageUrls[index]),
                        radius: 20,
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.pets),
                        radius: 20,
                      ),
                const SizedBox(width: 10),
                Text(itemNames[index]),
              ],
            ),
          );
        }),
        onChanged: onChanged,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
