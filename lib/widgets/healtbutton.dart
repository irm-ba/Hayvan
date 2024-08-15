import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption/aboutpage.dart';
import 'package:pet_adoption/constants.dart';
import 'package:pet_adoption/deneme_service.dart';
import 'package:pet_adoption/example.dart';
import 'package:pet_adoption/screens/IntroScreen.dart';
import 'package:pet_adoption/screens/home.dart';
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
    return MaterialApp();
  }
}

class HealthRecordHomePage extends StatelessWidget {
  const HealthRecordHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HealthRecordAdd(
                          petId: 'PET_ID')), // Geçerli bir pet ID'si ekleyin
                );
              },
              child: const Text('Sağlık Kaydı Ekle'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HealthRecordList()),
                );
              },
              child: const Text('Sağlık Kayıtlarını Görüntüle'),
            ),
          ],
        ),
      ),
    );
  }
}
