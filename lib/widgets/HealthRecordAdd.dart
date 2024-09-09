import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_adoption/models/healthRecords.dart';

class HealthRecordAdd extends StatefulWidget {
  const HealthRecordAdd({Key? key, required this.petId}) : super(key: key);

  final String petId;

  @override
  State<HealthRecordAdd> createState() => _HealthRecordAddState();
}

class _HealthRecordAddState extends State<HealthRecordAdd> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController veterinarianNameController =
      TextEditingController();
  final TextEditingController healthStatusController = TextEditingController();

  String? _selectedAnimalId;
  List<String> _animalIds = [];
  List<String> _animalNames = [];
  List<String> _animalImageUrls = [];
  File? _selectedImage;
  bool _isLoading = false;

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
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('animal_images')
        .child('${DateTime.now().toIso8601String()}.jpg');

    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  void _submitForm() async {
    if (dateController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        treatmentController.text.isEmpty ||
        veterinarianNameController.text.isEmpty ||
        healthStatusController.text.isEmpty ||
        _selectedAnimalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen tüm gerekli alanları doldurun.'),
        ),
      );
      return;
    }

    // Resim yüklemesi ve URL'yi alma
    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı oturum açmamış.'),
        ),
      );
      return;
    }

    // Sağlık kaydını oluştur
    final healthRecord = HealthRecord(
      petId: _selectedAnimalId!,
      date: Timestamp.fromDate(DateTime.parse(dateController.text)),
      description: descriptionController.text,
      treatment: treatmentController.text,
      veterinarianName: veterinarianNameController.text,
      healthStatus: healthStatusController.text,
      imageUrl: imageUrl ?? '', // Resim URL'si
      userId: user.uid, // Kullanıcı ID'si
    );

    try {
      // Firestore'a yeni sağlık kaydını ekle
      await FirebaseFirestore.instance
          .collection('healthRecords')
          .add(healthRecord.toMap());

      // Veri eklendikten sonra geri bildirim veya navigasyon yapabilirsiniz
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sağlık kaydı başarıyla eklendi!'),
        ),
      );

      // Formu sıfırlamak için gerekli kontrolleri ekleyebilirsiniz (isteğe bağlı)
      dateController.clear();
      descriptionController.clear();
      treatmentController.clear();
      veterinarianNameController.clear();
      healthStatusController.clear();
      setState(() {
        _selectedAnimalId = null; // Seçimi sıfırla
        _selectedImage = null;
      });
    } catch (e) {
      print('Firebase veri eklerken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sağlık kaydı eklenirken bir hata oluştu.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sağlık Kaydı Ekle"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Hayvan Seç",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              _buildDropdownField(
                label: 'Hayvan Seç',
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
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text("Resim Seç"),
              ),
              SizedBox(height: 10),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 150,
                ),
              SizedBox(height: 20),
              Text(
                "Tarih",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    dateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      hintText: "YYYY-MM-DD",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Açıklama",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Açıklama",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Tedavi",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: treatmentController,
                decoration: InputDecoration(
                  hintText: "Tedavi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Veterinerin Adı",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: veterinarianNameController,
                decoration: InputDecoration(
                  hintText: "Veterinerin Adı",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Sağlık Durumu",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: healthStatusController,
                decoration: InputDecoration(
                  hintText: "Sağlık Durumu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Ekle"),
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
        validator: (value) => value == null ? 'Lütfen bir hayvan seçin.' : null,
      ),
    );
  }
}
