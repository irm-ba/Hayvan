import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption/Contact.dart';
import 'package:pet_adoption/constants.dart';
import 'package:pet_adoption/account.dart';
import 'package:pet_adoption/models/pet_data.dart';
import 'package:pet_adoption/settings.dart';
import 'package:pet_adoption/aboutpage.dart';
import 'package:pet_adoption/widgets/CustomBottomNavigationBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/pet_grid_list.dart';
import '../Contact.dart';
import '../login.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedCategory = 'Tüm İlanlar';
  String selectedAnimalType = '';
  String ageRange = '';
  String location = '';
  String? selectedBreed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavigationBar(),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: kBrownColor,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profil'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Ayarlar'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.announcement_outlined),
                title: Text('Bize Ulaşın'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.accessibility_new_sharp),
                title: Text('Hakkımızda'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                  );
                },
              ),
              Divider(), // Bölüm çizgisi ekliyoruz
              ListTile(
                leading: Icon(Icons.accessibility_new_sharp),
                title: Text('Çıkış yap'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: IconButton(
                    icon: Icon(Icons.menu_rounded, color: kBrownColor),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              );
            },
          ),
          title: Center(
            child: Text('Felvera'),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                _showFilterDialog();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            /// Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton('Tüm İlanlar'),
                  _buildCategoryButton('Kedi İlanları'),
                  _buildCategoryButton('Kayıp İlanları'),
                  _buildCategoryButton('Köpek İlanları'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Pet List
            Expanded(
              child: StreamBuilder(
                stream: _getCategoryStream(selectedCategory),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Hata oluştu: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Hiç hayvan bulunamadı.'));
                  }

                  // Firestore'dan gelen verileri PetData listesine dönüştürme
                  List<PetData> pets =
                      snapshot.data!.docs.map((DocumentSnapshot doc) {
                    return PetData.fromSnapshot(doc);
                  }).toList();

                  return PetGridList(pets: pets);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: selectedCategory == category ? kBrownColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: selectedCategory == category ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getCategoryStream(String category) {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('pet');

    Query query = collection;

    if (category == 'Kayıp İlanları') {
      query = FirebaseFirestore.instance.collection('lost_animals');
    } else if (category == 'Kedi İlanları') {
      query = collection.where('animalType', isEqualTo: 'Kedi');
    } else if (category == 'Köpek İlanları') {
      query = collection.where('animalType', isEqualTo: 'Köpek');
    }

    // Filtreleme kriterlerini uygulama
    if (selectedAnimalType.isNotEmpty) {
      query = query.where('animalType', isEqualTo: selectedAnimalType);
    }

    if (selectedBreed != null && selectedBreed!.isNotEmpty) {
      query = query.where('breed', isEqualTo: selectedBreed);
    }

    if (ageRange.isNotEmpty) {
      // Yaş aralığını işleme
      List<String> ageRangeParts = ageRange.split('-');
      if (ageRangeParts.length == 2) {
        int minAge = int.tryParse(ageRangeParts[0].trim()) ?? 0;
        int maxAge = int.tryParse(ageRangeParts[1].trim()) ?? 0;
        query = query
            .where('age', isGreaterThanOrEqualTo: minAge)
            .where('age', isLessThanOrEqualTo: maxAge);
      }
    }

    if (location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    return query.snapshots();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtrele'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hayvan türü seçimi
                  DropdownButton<String>(
                    value: selectedAnimalType.isNotEmpty
                        ? selectedAnimalType
                        : null,
                    hint: Text('Hayvan Türü'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAnimalType = newValue ?? '';
                      });
                    },
                    items: [
                      'Kedi',
                      'Köpek',
                      'Kuş',
                      'Balık',
                      'Hamster',
                      'Tavşan',
                      'Kaplumbağa',
                      'Yılan',
                      'Kertenkele',
                      'Sürüngen',
                      'Böcek',
                      'Diğer'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  // Breed seçimi
                  FutureBuilder<List<String>>(
                    future: _fetchBreeds(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Hata oluştu: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('');
                      }
                      List<String> breeds = snapshot.data!;

                      return DropdownButton<String>(
                        value: selectedBreed,
                        hint: Text('Cins'),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBreed = newValue;
                          });
                        },
                        items: breeds
                            .map<DropdownMenuItem<String>>((String breed) {
                          return DropdownMenuItem<String>(
                            value: breed,
                            child: Text(breed),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  // Yaş aralığı seçimi
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Yaş Aralığı (ör. 1-5)',
                    ),
                    onChanged: (value) {
                      setState(() {
                        ageRange = value;
                      });
                    },
                  ),
                  // Konum seçimi
                  DropdownButton<String>(
                    value: location.isNotEmpty ? location : null,
                    hint: Text('Konum'),
                    onChanged: (String? newValue) {
                      setState(() {
                        location = newValue ?? '';
                      });
                    },
                    items: [
                      'Adana',
                      'Adıyaman',
                      'Afyonkarahisar',
                      'Ağrı',
                      'Aksaray',
                      'Amasya',
                      'Ankara',
                      'Antalya',
                      'Ardahan',
                      'Artvin',
                      'Aydın',
                      'Balıkesir',
                      'Bartın',
                      'Batman',
                      'Bayburt',
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
                      'Kayseri',
                      'Kırıkkale',
                      'Kırklareli',
                      'Kırşehir',
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
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // İptal butonuna basıldığında filtreleme değerlerini sıfırla
                  selectedAnimalType = '';
                  selectedBreed = null;
                  ageRange = '';
                  location = '';
                });
              },
            ),
            TextButton(
              child: Text('Uygula'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // Filtreleme değerlerini güncelle
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _fetchBreeds() async {
    // Firestore'dan cins bilgilerini al
    final snapshot =
        await FirebaseFirestore.instance.collection('breeds').get();
    return snapshot.docs.map((doc) => doc['name'].toString()).toList();
  }
}
