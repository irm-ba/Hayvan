import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption/Contact.dart';
import 'package:pet_adoption/Event.dart';
import 'package:pet_adoption/chatList.dart';
import 'package:pet_adoption/chatPage.dart';
import 'package:pet_adoption/constants.dart';
import 'package:pet_adoption/account.dart';
import 'package:pet_adoption/models/pet_data.dart';
import 'package:pet_adoption/aboutpage.dart';
import 'package:pet_adoption/widgets/CustomBottomNavigationBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption/widgets/lostanimalpge.dart';
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
                    ListTile(
                      leading: Icon(Icons.chat_outlined,
                          color: Color.fromARGB(255, 147, 58, 142)),
                      title: Text('Mesaj'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatListPage()),
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
                          MaterialPageRoute(builder: (context) => LoginPage()),
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
            builder: (context) => Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                child: IconButton(
                  icon: Icon(Icons.menu_rounded, color: kBrownColor),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
          ),
          title: Center(
            child:
                Text('Felvera', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  _showFilterDialog();
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            /// Kategoriler
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton('Tüm İlanlar'),
                  _buildCategoryButton('Kayıp İlanları'),
                  _buildCategoryButton('Gönüllülük Etkinlikleri'),
                  _buildCategoryButton('Forum'),
                  _buildCategoryButton('Blog'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: selectedCategory == 'Blog'
                  ? BlogPage()
                  : selectedCategory == 'Forum'
                      ? ForumPage()
                      : selectedCategory == 'Gönüllülük Etkinlikleri'
                          ? EventPage()
                          : selectedCategory == 'Kayıp İlanları'
                              ? LostAnimalsPage()
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
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category, {bool isNavigable = false}) {
    return GestureDetector(
      onTap: () {
        if (category == 'Kayıp İlanları' && isNavigable) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LostAnimalsPage()),
          );
        } else {
          setState(() {
            selectedCategory = category;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: selectedCategory == category
              ? Color.fromARGB(255, 147, 58, 142)
              : Colors.grey[300],
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
}
