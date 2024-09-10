import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_adoption/screens/IntroScreen.dart';
import 'package:pet_adoption/screens/home.dart';
import 'package:pet_adoption/login.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<Widget> _initialPage;

  @override
  void initState() {
    super.initState();
    _initialPage = _getInitialPage();
  }

  Future<Widget> _getInitialPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı giriş yapmışsa, ana sayfayı göster
      return Home();
    } else if (hasSeenIntro) {
      // Tanıtım ekranı daha önce gösterildiyse, giriş ekranını göster
      return LoginPage();
    } else {
      // Tanıtım ekranı daha önce gösterilmemişse, tanıtım ekranını göster
      return IntroScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _initialPage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return Scaffold(
            body: Center(child: Text('Error loading page')),
          );
        }
      },
    );
  }
}
