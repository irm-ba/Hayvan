import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption/aboutpage.dart';
import 'package:pet_adoption/constants.dart';
import 'package:pet_adoption/deneme_service.dart';
import 'package:pet_adoption/example.dart';
import 'package:pet_adoption/login.dart';
import 'package:pet_adoption/screens/IntroScreen.dart';
import 'package:pet_adoption/screens/home.dart';
import 'package:pet_adoption/sign_up.dart';
import 'package:pet_adoption/widgets/healtbutton.dart';
import 'firebase/auth.dart';
import 'package:pet_adoption/widgets/HealthRecordAdd.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    runApp(MyApp());
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Felvera',
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor,
          iconTheme: IconThemeData(color: kBrownColor),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: kBrownColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
