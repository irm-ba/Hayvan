import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption/Contact.dart';
import 'package:pet_adoption/Event.dart';
import 'package:pet_adoption/constants.dart';
import 'package:pet_adoption/account.dart';
import 'package:pet_adoption/models/pet_data.dart';
import 'package:pet_adoption/aboutpage.dart';
import 'package:pet_adoption/widgets/CustomBottomNavigationBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/pet_grid_list.dart';
import '../login.dart';
import '../forum.dart';
import 'package:pet_adoption/blogPage.dart';
// EventPage import edildi

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(),
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 147, 58, 142), // Kbrown rengi
                        Color.fromARGB(255, 169, 85, 210) // İkinci renk
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.3, 0.7], // Geçişlerin belirgin olduğu noktalar
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        title: Text('Profil'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AccountPage()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.announcement_outlined,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        title: Text('Bize Ulaşın'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactPage()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.accessibility_new_sharp,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        title: Text('Hakkımızda'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutUsPage()),
                          );
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout_rounded,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        title: Text('Çıkış yap'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
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
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.0), // İkon ve yazı arasında boşluk
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {
                        _showFilterDialog();
                      },
                    ),
                  ],
                ),
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
                    _buildCategoryButton('Kayıp İlanları'),
                    _buildCategoryButton(
                        'Gönüllülük Etkinlikleri'), // Bu seçeneği değiştirdik
                    _buildCategoryButton('Forum'),
                    _buildCategoryButton('Blog'), // Blog seçeneği ekliyoruz
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: selectedCategory == 'Blog'
                    ? BlogPage() // Blog sayfasını burada gösteriyoruz
                    : selectedCategory == 'Forum'
                        ? ForumPage()
                        : selectedCategory ==
                                'Gönüllülük Etkinlikleri' // Burayı da değiştirdik
                            ? EventPage() // EventPage, Gönüllülük Etkinlikleri olarak değiştirildi
                            : StreamBuilder(
                                stream: _getCategoryStream(selectedCategory),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Hata oluştu: ${snapshot.error}'));
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text(
                                        selectedCategory ==
                                                'Gönüllülük Etkinlikleri'
                                            ? 'Henüz gönüllülük etkinliği bulunmamaktadır.'
                                            : 'Hiç hayvan bulunamadı.',
                                      ),
                                    );
                                  }

                                  // Firestore'dan gelen verileri PetData listesine dönüştürme
                                  List<PetData> pets = snapshot.data!.docs
                                      .map((DocumentSnapshot doc) {
                                    return PetData.fromSnapshot(doc);
                                  }).toList();

                                  return PetGridList(pets: pets);
                                },
                              ),
              ),
            ],
          )),
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
    } else if (category == 'Gönüllülük Etkinlikleri') {
      return FirebaseFirestore.instance
          .collection('volunteering_events')
          .snapshots();
    }

    // Filtreleme kriterlerini uygulama
    if (selectedAnimalType.isNotEmpty) {
      query = query.where('animalType', isEqualTo: selectedAnimalType);
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
          title: Text('Filtreleme Seçenekleri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedAnimalType,
                hint: Text('Hayvan Türü Seçin'),
                items: <String>[
                  '',
                  'Kedi',
                  'Köpek',
                  'Kuş',
                  'Tavşan',
                  'Hamster',
                  'Diğer'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAnimalType = value!;
                  });
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Yaş Aralığı (örn. 1-5)'),
                initialValue: ageRange,
                onChanged: (value) {
                  setState(() {
                    ageRange = value;
                  });
                },
              ),
              DropdownButton<String>(
                value: location,
                hint: Text('Konum Seçin'),
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
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    location = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text('Filtrele'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {}); // Filtreleme sonrası yenileme
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrownColor, // Mor renk
              ),
            ),
            TextButton(
              child: Text('Sıfırla'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedAnimalType = '';
                  ageRange = '';
                  location = '';
                });
              },
            ),
          ],
        );
      },
    );
  }
}
