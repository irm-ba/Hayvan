import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hayvan İlanları"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "İlan Ekle"),
            Tab(text: "Kayıp İlan Ekle"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProductAdd(),
          LostAnimalAdd(),
        ],
      ),
    );
  }
}

class ProductAdd extends StatefulWidget {
  const ProductAdd({Key? key}) : super(key: key);

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController healthStatusController = TextEditingController();
  final TextEditingController animalTypeController = TextEditingController();

  String? selectedLocation;
  bool isGenderMale = true;
  List<File> _images = [];
  File? _healthCardImage;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      } else {
        print('Resim seçilmedi');
      }
    });
  }

  Future<void> _getHealthCardImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _healthCardImage = File(pickedFile.path);
      } else {
        print('Sağlık kartı resmi seçilmedi');
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<String?> _uploadFile(File file, String folder) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('$folder/${Uuid().v4()}');
    try {
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Dosya yükleme hatası: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı oturum açmamış.'),
        ),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        breedController.text.isEmpty ||
        ageController.text.isEmpty ||
        _images.isEmpty ||
        healthStatusController.text.isEmpty ||
        selectedLocation == null ||
        animalTypeController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Lütfen tüm zorunlu alanları doldurun ve resim ekleyin.'),
        ),
      );
      return;
    }

    String userId = user.uid; // Kullanıcının ID'sini al
    String petId = Uuid().v4(); // Benzersiz bir kimlik

    // Fotoğrafları ve sağlık kartını Firebase Storage'a yükleyin
    List<String> imageUrls = [];
    for (var image in _images) {
      var imageUrl = await _uploadFile(image, 'pet_images');
      if (imageUrl != null) imageUrls.add(imageUrl);
    }
    String? healthCardUrl = _healthCardImage != null
        ? await _uploadFile(_healthCardImage!, 'health_card_images')
        : null;

    final newPet = PetData(
      name: nameController.text,
      breed: breedController.text,
      isGenderMale: isGenderMale,
      age: int.parse(ageController.text),
      imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : '',
      healthStatus: healthStatusController.text,
      healthCardImageUrl: healthCardUrl ?? '',
      description: descriptionController.text,
      personalityTraits: 'Kişilik özellikleri eksik',
      animalType: animalTypeController.text,
      location: selectedLocation!,
      userId: userId,
      petId: petId,
    );

    // Firestore'a veri ekleme
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('pet').doc(petId).set({
      'name': newPet.name,
      'breed': newPet.breed,
      'isGenderMale': newPet.isGenderMale,
      'age': newPet.age,
      'imageUrl': newPet.imageUrl,
      'healthStatus': newPet.healthStatus,
      'healthCardImageUrl': newPet.healthCardImageUrl,
      'description': newPet.description,
      'personalityTraits': newPet.personalityTraits,
      'animalType': newPet.animalType,
      'location': newPet.location,
      'userId': newPet.userId,
      'petId': newPet.petId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hayvan başarıyla eklendi!'),
      ),
    );

    // Formu sıfırlama
    nameController.clear();
    breedController.clear();
    ageController.clear();
    descriptionController.clear();
    healthStatusController.clear();
    animalTypeController.clear();
    setState(() {
      _images.clear();
      _healthCardImage = null;
      selectedLocation = null;
      isGenderMale = true; // Default gender
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> cities = [
      'Adana',
      'Adıyaman',
      'Afyonkarahisar',
      'Ağrı',
      'Aksaray',
      'Amasya',
      'Ankara',
      'Antalya',
      'Artvin',
      'Aydın',
      'Balıkesir',
      'Bilecik',
      'Bingöl',
      'Bitlis',
      'Bolu',
      'Burdur',
      'Bursa',
      'Çanakkale',
      'Çankırı',
      'Çorum',
      'Denizli',
      'Diyarbakır',
      'Düzce',
      'Edirne',
      'Elazığ',
      'Erzincan',
      'Erzurum',
      'Eskişehir',
      'Gaziantep',
      'Giresun',
      'Gümüşhane',
      'Hakkari',
      'Hatay',
      'Iğdır',
      'Isparta',
      'İstanbul',
      'İzmir',
      'Kahramanmaraş',
      'Karabük',
      'Karaman',
      'Kars',
      'Kastamonu',
      'Kayseri',
      'Kırıkkale',
      'Kırklareli',
      'Kırşehir',
      'Kilis',
      'Kocaeli',
      'Konya',
      'Kütahya',
      'Malatya',
      'Manisa',
      'Mardin',
      'Mersin',
      'Muğla',
      'Muş',
      'Nevşehir',
      'Niğde',
      'Ordu',
      'Osmaniye',
      'Rize',
      'Sakarya',
      'Samsun',
      'Siirt',
      'Sinop',
      'Sivas',
      'Şanlıurfa',
      'Şırnak',
      'Tekirdağ',
      'Tokat',
      'Trabzon',
      'Tunceli',
      'Uşak',
      'Van',
      'Yalova',
      'Yozgat',
      'Zonguldak'
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Hayvan Adı'),
          ),
          TextField(
            controller: breedController,
            decoration: InputDecoration(labelText: 'Cinsi'),
          ),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Yaşı'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Açıklama'),
          ),
          TextField(
            controller: healthStatusController,
            decoration: InputDecoration(labelText: 'Sağlık Durumu'),
          ),
          TextField(
            controller: animalTypeController,
            decoration: InputDecoration(labelText: 'Hayvan Türü'),
          ),
          DropdownButtonFormField<String>(
            value: selectedLocation,
            decoration: InputDecoration(labelText: 'Konum'),
            items: cities.map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedLocation = newValue;
              });
            },
          ),
          Row(
            children: [
              Text('Cinsiyet: '),
              Radio(
                value: true,
                groupValue: isGenderMale,
                onChanged: (bool? value) {
                  setState(() {
                    isGenderMale = value ?? true;
                  });
                },
              ),
              Text('Erkek'),
              Radio(
                value: false,
                groupValue: isGenderMale,
                onChanged: (bool? value) {
                  setState(() {
                    isGenderMale = value ?? false;
                  });
                },
              ),
              Text('Dişi'),
            ],
          ),
          ElevatedButton(
            onPressed: _getImage,
            child: Text('Resim Seç'),
          ),
          _images.isEmpty
              ? Text('Resim seçilmedi')
              : Wrap(
                  spacing: 8.0,
                  children: List.generate(_images.length, (index) {
                    return Stack(
                      children: [
                        Image.file(
                          _images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _getHealthCardImage,
            child: Text('Sağlık Kartı Resmi Seç'),
          ),
          _healthCardImage == null
              ? Text('Sağlık kartı resmi seçilmedi')
              : Image.file(
                  _healthCardImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('İlanı Gönder'),
          ),
        ],
      ),
    );
  }
}

class PetData {
  final String name;
  final String breed;
  final bool isGenderMale;
  final int age;
  final String imageUrl;
  final String healthStatus;
  final String healthCardImageUrl;
  final String description;
  final String personalityTraits;
  final String animalType;
  final String location;
  final String userId;
  final String petId;

  PetData({
    required this.name,
    required this.breed,
    required this.isGenderMale,
    required this.age,
    required this.imageUrl,
    required this.healthStatus,
    required this.healthCardImageUrl,
    required this.description,
    required this.personalityTraits,
    required this.animalType,
    required this.location,
    required this.userId,
    required this.petId,
  });
}

class LostAnimalAdd extends StatefulWidget {
  @override
  _LostAnimalAddState createState() => _LostAnimalAddState();
}

class _LostAnimalAddState extends State<LostAnimalAdd> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedLocation;
  bool isGenderMale = true;
  List<File> _images = [];
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      } else {
        print('Resim seçilmedi');
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<String?> _uploadFile(File file, String folder) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('$folder/${Uuid().v4()}');
    try {
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Dosya yükleme hatası: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı oturum açmamış.'),
        ),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        breedController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        _images.isEmpty ||
        selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Lütfen tüm zorunlu alanları doldurun ve resim ekleyin.'),
        ),
      );
      return;
    }

    String userId = user.uid; // Kullanıcının ID'sini al
    String lostAnimalId = Uuid().v4(); // Benzersiz bir kimlik

    // Fotoğrafları Firebase Storage'a yükleyin
    List<String> imageUrls = [];
    for (var image in _images) {
      var imageUrl = await _uploadFile(image, 'lost_animal_images');
      if (imageUrl != null) imageUrls.add(imageUrl);
    }

    final newLostAnimal = LostAnimalData(
      name: nameController.text,
      breed: breedController.text,
      isGenderMale: isGenderMale,
      imageUrls: imageUrls,
      description: descriptionController.text,
      location: selectedLocation!,
      userId: userId,
      lostAnimalId: lostAnimalId,
    );

    // Firestore'a veri ekleme
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('lost_animals').doc(lostAnimalId).set({
      'name': newLostAnimal.name,
      'breed': newLostAnimal.breed,
      'isGenderMale': newLostAnimal.isGenderMale,
      'imageUrls': newLostAnimal.imageUrls,
      'description': newLostAnimal.description,
      'location': newLostAnimal.location,
      'userId': newLostAnimal.userId,
      'lostAnimalId': newLostAnimal.lostAnimalId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kayıp hayvan ilanı başarıyla eklendi!'),
      ),
    );

    // Formu sıfırlama
    nameController.clear();
    breedController.clear();
    descriptionController.clear();
    setState(() {
      _images.clear();
      selectedLocation = null;
      isGenderMale = true; // Default gender
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> cities = [
      'Adana',
      'Adıyaman',
      'Afyonkarahisar',
      'Ağrı',
      'Aksaray',
      'Amasya',
      'Ankara',
      'Antalya',
      'Artvin',
      'Aydın',
      'Balıkesir',
      'Bilecik',
      'Bingöl',
      'Bitlis',
      'Bolu',
      'Burdur',
      'Bursa',
      'Çanakkale',
      'Çankırı',
      'Çorum',
      'Denizli',
      'Diyarbakır',
      'Düzce',
      'Edirne',
      'Elazığ',
      'Erzincan',
      'Erzurum',
      'Eskişehir',
      'Gaziantep',
      'Giresun',
      'Gümüşhane',
      'Hakkari',
      'Hatay',
      'Iğdır',
      'Isparta',
      'İstanbul',
      'İzmir',
      'Kahramanmaraş',
      'Karabük',
      'Karaman',
      'Kars',
      'Kastamonu',
      'Kayseri',
      'Kırıkkale',
      'Kırklareli',
      'Kırşehir',
      'Kilis',
      'Kocaeli',
      'Konya',
      'Kütahya',
      'Malatya',
      'Manisa',
      'Mardin',
      'Mersin',
      'Muğla',
      'Muş',
      'Nevşehir',
      'Niğde',
      'Ordu',
      'Osmaniye',
      'Rize',
      'Sakarya',
      'Samsun',
      'Siirt',
      'Sinop',
      'Sivas',
      'Şanlıurfa',
      'Şırnak',
      'Tekirdağ',
      'Tokat',
      'Trabzon',
      'Tunceli',
      'Uşak',
      'Van',
      'Yalova',
      'Yozgat',
      'Zonguldak'
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Hayvan Adı'),
          ),
          TextField(
            controller: breedController,
            decoration: InputDecoration(labelText: 'Cinsi'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Açıklama'),
          ),
          DropdownButtonFormField<String>(
            value: selectedLocation,
            decoration: InputDecoration(labelText: 'Konum'),
            items: cities.map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedLocation = newValue;
              });
            },
          ),
          Row(
            children: [
              Text('Cinsiyet: '),
              Radio(
                value: true,
                groupValue: isGenderMale,
                onChanged: (bool? value) {
                  setState(() {
                    isGenderMale = value ?? true;
                  });
                },
              ),
              Text('Erkek'),
              Radio(
                value: false,
                groupValue: isGenderMale,
                onChanged: (bool? value) {
                  setState(() {
                    isGenderMale = value ?? false;
                  });
                },
              ),
              Text('Dişi'),
            ],
          ),
          ElevatedButton(
            onPressed: _getImage,
            child: Text('Resim Seç'),
          ),
          _images.isEmpty
              ? Text('Resim seçilmedi')
              : Wrap(
                  spacing: 8.0,
                  children: List.generate(_images.length, (index) {
                    return Stack(
                      children: [
                        Image.file(
                          _images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Kayıp İlanını Gönder'),
          ),
        ],
      ),
    );
  }
}

class LostAnimalData {
  final String name;
  final String breed;
  final bool isGenderMale;
  final List<String> imageUrls;
  final String description;
  final String location;
  final String userId;
  final String lostAnimalId;

  LostAnimalData({
    required this.name,
    required this.breed,
    required this.isGenderMale,
    required this.imageUrls,
    required this.description,
    required this.location,
    required this.userId,
    required this.lostAnimalId,
  });
}
