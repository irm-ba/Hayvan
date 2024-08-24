import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pet_adoption/vaccination_schedule_add.dart';
import 'package:pet_adoption/vaccination_schedule_list.dart';
import 'package:pet_adoption/vet_visit_add.dart';
import 'package:pet_adoption/vet_visit_list.dart';

import 'package:pet_adoption/widgets/HealthRecordAdd.dart';
import 'package:pet_adoption/widgets/healtRecordList.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[800]),
          bodyMedium: TextStyle(color: Colors.grey[600]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 147, 58, 142),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Yuvarlatılmış köşeler
            ),
            elevation: 5, // Hafif gölge
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(
            color: Color.fromARGB(255, 147, 58, 142),
          ),
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 147, 58, 142),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCategoryCard(
              context,
              title: 'Sağlık Kaydı',
              icon: Icons.medical_services,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HealthRecordHomePage()),
                );
              },
            ),
            _buildCategoryCard(
              context,
              title: 'Aşı Takvimi',
              icon: Icons.calendar_today,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VaccinationScheduleHomePage()),
                );
              },
            ),
            _buildCategoryCard(
              context,
              title: 'Veteriner Ziyareti',
              icon: Icons.pets,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VetVisitHomePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Color.fromARGB(255, 147, 58, 142),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 147, 58, 142),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthRecordHomePage extends StatelessWidget {
  const HealthRecordHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sağlık Kaydı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildActionButton(
              context,
              title: 'Sağlık Kaydı Ekle',
              icon: Icons.add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HealthRecordAdd(
                          petId: 'PET_ID')), // Geçerli bir pet ID'si ekleyin
                );
              },
            ),
            SizedBox(height: 20),
            _buildActionButton(
              context,
              title: 'Sağlık Kayıtlarını Görüntüle',
              icon: Icons.visibility,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HealthRecordList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 147, 58, 142),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          elevation: 5,
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class VaccinationScheduleHomePage extends StatelessWidget {
  const VaccinationScheduleHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aşı Takvimi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildActionButton(
              context,
              title: 'Aşı Takvimi Ekle',
              icon: Icons.add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VaccinationScheduleAdd()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildActionButton(
              context,
              title: 'Aşı Takvimlerini Görüntüle',
              icon: Icons.visibility,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VaccinationScheduleList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 147, 58, 142),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          elevation: 5,
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class VetVisitHomePage extends StatelessWidget {
  const VetVisitHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veteriner Ziyareti'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildActionButton(
              context,
              title: 'Veteriner Ziyareti Ekle',
              icon: Icons.add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VetVisitAdd()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildActionButton(
              context,
              title: 'Veteriner Ziyaretlerini Görüntüle',
              icon: Icons.visibility,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VetVisitList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 147, 58, 142),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          elevation: 5,
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
