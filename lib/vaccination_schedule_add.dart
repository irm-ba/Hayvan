import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _visitDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedAnimalId;
  List<String> _animalIds = [];
  List<String> _animalNames = [];
  List<String> _animalImageUrls = [];
  File? _selectedImage;
  bool _isLoading = false;

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

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final imageRef = storageRef.child('vaccination_images/$fileName');
      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
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
          if (_selectedImage != null) {
            imageUrl = await _uploadImage(_selectedImage!);
          }

          await FirebaseFirestore.instance
              .collection('vaccinationSchedules')
              .add({
            'description': _descriptionController.text,
            'start': start,
            'end': end,
            'animalId': _selectedAnimalId,
            'userId': user.uid,
            'animalImageUrl': imageUrl,
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
                          'Aşı takvimi bilgilerini doldurun.',
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
                          onTap: _selectDateRange,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _visitDateController,
                              label: 'Tarih Aralığı',
                              hint: 'Başlangıç - Bitiş',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tarih aralığı girin';
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
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveVaccinationSchedule,
                          child: const Text('Kaydet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 147, 58, 142),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            textStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
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
      child: InkWell(
        onTap: _pickImage,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.camera_alt, size: 50, color: Colors.grey),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  _selectedImage != null
                      ? 'Resmi değiştirmek için dokunun'
                      : 'Resim ekleyin',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedStart != null && pickedStart != start) {
      final DateTime? pickedEnd = await showDatePicker(
        context: context,
        initialDate: end ?? pickedStart,
        firstDate: pickedStart,
        lastDate: DateTime(2100),
      );
      if (pickedEnd != null && pickedEnd != end) {
        setState(() {
          start = pickedStart;
          end = pickedEnd;
          _visitDateController.text =
              '${start?.toLocal().toString().split(' ')[0]} - ${end?.toLocal().toString().split(' ')[0]}';
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required FormFieldValidator<String> validator,
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
